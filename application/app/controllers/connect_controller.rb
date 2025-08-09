class ConnectController < ApplicationController
  include LoggingCommon
  include ConnectorResponse

  before_action :parse_connector_type

  def show
    processor = ConnectorClassDispatcher.connect_connector_processor(@connector_type)
    processor_params = params.permit(*processor.params_schema).to_h
    result = processor.show(processor_params)

    unless result.success?
      log_error('Connect.show action error', { connector_type: @connector_type, processor: processor.class.name, action: object_type }.merge(result.message))
      return respond_error(result.message, root_path)
    end

    log_info('Connect.show completed', { connector_type: @connector_type, processor: processor.class.name, action: object_type })
    respond_success(result)
  rescue => e
    log_error('Error processing Connect.show processor/action', { connector_type: @connector_type, action: object_type }, e)
    respond_error({ alert: I18n.t('connect.show.message_processor_error', connector_type: @connector_type, action: object_type) }, root_path)
  end

  def handle
    processor = ConnectorClassDispatcher.connect_connector_processor(@connector_type)
    processor_params = params.permit(*processor.params_schema).to_h
    result = processor.handle(processor_params)

    unless result.success?
      log_error('Connect.handle action error', { connector_type: @connector_type, action: object_type }.merge(result.message))
      return respond_error(result.message, root_path)
    end

    log_info('Connect.handle completed', { connector_type: @connector_type, action: object_type })
    respond_success(result)
  rescue => e
    log_error('Error processing Connect.handle processor/action', { connector_type: @connector_type, action: object_type }, e)
    respond_error({ alert: I18n.t('connect.handle.message_processor_error', connector_type: @connector_type, action: object_type) }, root_path)
  end

  private

  def object_type
    params[:object_type]
  end
end
