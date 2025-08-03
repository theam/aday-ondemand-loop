class ExploreController < ApplicationController
  include LoggingCommon

  def show
    connector_type = ConnectorType.get(params[:connector_type])
    repo_url = UrlParser.build(
      params[:server_domain],
      scheme: params[:server_scheme],
      port: params[:server_port]
    )

    if repo_url.nil?
      redirect_back fallback_location: root_path, alert: I18n.t('explore.show.message_invalid_repo_url')
      return
    end

    processor = ConnectorClassDispatcher.explore_connector_processor(connector_type)
    processor_params = params.permit(*processor.params_schema).to_h.merge(repo_url: repo_url)
    log_info('Explore', processor_params)
    result = processor.show(processor_params)

    if result.message.present?
      result.message.each { |k, v| flash.now[k] = v }
    end
    render template: result.template, locals: result.locals
  end
end
