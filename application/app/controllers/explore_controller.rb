class ExploreController < ApplicationController
  include LoggingCommon

  def show
    connector_type = ConnectorType.get(params[:connector_type])
    repo_url = Repo::RepoUrl.build(
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
    log_info('Explore show', { repo_url: repo_url, connector_type: connector_type, object_type: params[:object_type], object_id: params[:object_id] })
    result = processor.show(processor_params)

    return redirect_to root_path, **result.message unless result.success?

    render template: result.template, locals: result.locals
  end

  def create
    connector_type = ConnectorType.get(params[:connector_type])
    repo_url = Repo::RepoUrl.build(
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
    log_info('Explore create', { repo_url: repo_url, connector_type: connector_type, object_type: params[:object_type], object_id: params[:object_id] })
    result = processor.create(processor_params)

    redirect_back fallback_location: root_path, **result.message
  end
end
