class ExploreController < ApplicationController
  include LoggingCommon

  def show
    connector_type = ConnectorType.get(params[:connector_type])
    processor = ConnectorClassDispatcher.explore_connector_processor(connector_type)
    processor_params = params.permit(*processor.params_schema).to_h
    log_info('Explore', processor_params)
    result = processor.show(processor_params)

    if result.message.present?
      result.message.each { |k, v| flash.now[k] = v }
    end
    render template: result.template, locals: result.locals
  end
end
