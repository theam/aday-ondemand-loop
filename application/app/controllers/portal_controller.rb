class PortalController < ApplicationController
  include LoggingCommon

  before_action :parse_connector_type

  def handle
    dispatch_action(params[:action])
  end

  def action_missing(name, *_args)
    dispatch_action(name.to_s)
  end

  private

  def dispatch_action(action_name)
    processor = ConnectorActionDispatcher.action(@connector_type, action_name)
    processor_params = if processor.respond_to?(:params_schema)
                         params.permit(*processor.params_schema).to_h
                       else
                         params.to_unsafe_h
                       end
    result = request.get? ? processor.show(processor_params) : processor.create(processor_params)

    unless result.success?
      log_error('Portal.handle action error', { connector_type: @connector_type, action: action_name }.merge(result.message))
      return respond_error(result.message, root_path)
    end

    respond_success(result)
    log_info('Portal.handle completed', { connector_type: @connector_type, action: action_name })
  rescue => e
    log_error('Error processing Portal.handle processor/action', { connector_type: @connector_type, action: action_name }, e)
    respond_error({ alert: I18n.t('portal.handle.message_processor_error', connector_type: @connector_type, action: action_name) }, root_path)
  end

  def respond_success(result)
    if ajax_request?
      render partial: result.template, locals: result.locals, layout: false
    else
      render template: result.template, locals: result.locals
    end
  end

  def respond_error(message_hash, redirect_path)
    if ajax_request?
      apply_flash_now(message_hash)
      render partial: 'layouts/flash_messages', status: :internal_server_error, layout: false
    else
      redirect_to redirect_path, **message_hash
    end
  end

  def apply_flash_now(message_hash)
    (message_hash || {}).each { |k, v| flash.now[k] = v }
  end

  def parse_connector_type
    @connector_type = ConnectorType.get(params[:connector_type])
  rescue ArgumentError => e
    log_error('Invalid connector type', { connector_type: params[:connector_type] }, e)
    redirect_to root_path, alert: I18n.t('portal.message_invalid_connector_type', connector_type: params[:connector_type])
  end
end
