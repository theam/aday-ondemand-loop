class ConnectController < ApplicationController
  include LoggingCommon
  include ConnectorResponse

  before_action :parse_connector_type

  def handle
    dispatch_action(params[:action])
  end

  def action_missing(name, *_args)
    dispatch_action(name.to_s)
  end

  private

  def dispatch_action(action_name)
    processor = ConnectorClassDispatcher.connect_connector_processor(@connector_type)
    action = processor.action(action_name)
    processor_params = if action.respond_to?(:params_schema)
                         params.permit(*action.params_schema).to_h
                       else
                         params.to_unsafe_h
                       end
    result = request.get? ? action.show(processor_params) : action.create(processor_params)

    unless result.success?
      log_error('Connect.handle action error', { connector_type: @connector_type, action: action_name }.merge(result.message))
      return respond_error(result.message, root_path)
    end

    respond_success(result)
    log_info('Connect.handle completed', { connector_type: @connector_type, action: action_name })
  rescue => e
    log_error('Error processing Connect.handle processor/action', { connector_type: @connector_type, action: action_name }, e)
    respond_error({ alert: I18n.t('connect.handle.message_processor_error', connector_type: @connector_type, action: action_name) }, root_path)
  end
end
