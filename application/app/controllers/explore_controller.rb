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
      redirect_back fallback_location: root_path, alert: I18n.t('explore.show.message_invalid_repo_url', repo_url: repo_url.to_s)
      return
    end

    processor = ConnectorClassDispatcher.explore_connector_processor(connector_type)
    processor_params = params.permit(*processor.params_schema).to_h.merge(repo_url: repo_url)
    result = processor.show(processor_params)

    unless result.success?
      log_error('Explore.show action error', { repo_url: repo_url, connector_type: connector_type, processor: processor.class.name, object_type: params[:object_type], object_id: params[:object_id] }.merge(result.message))
      return redirect_to root_path, **result.message
    end

    render template: result.template, locals: result.locals
    log_info('Explore.show completed', { repo_url: repo_url, connector_type: connector_type, object_type: params[:object_type], object_id: params[:object_id] })
  rescue => e
    log_error('Error processing Explore.show processor/action', { connector_type: connector_type, object_type: params[:object_type], object_id: params[:object_id] }, e)
    return redirect_to root_path, alert: I18n.t('explore.show.message_processor_error', connector_type: connector_type, object_type: params[:object_type], object_id: params[:object_id])
  end

  def create
    connector_type = ConnectorType.get(params[:connector_type])
    repo_url = Repo::RepoUrl.build(
      params[:server_domain],
      scheme: params[:server_scheme],
      port: params[:server_port]
    )

    if repo_url.nil?
      redirect_back fallback_location: root_path, alert: I18n.t('explore.create.message_invalid_repo_url', repo_url: repo_url.to_s)
      return
    end

    processor = ConnectorClassDispatcher.explore_connector_processor(connector_type)
    processor_params = params.permit(*processor.params_schema).to_h.merge(repo_url: repo_url)
    result = processor.create(processor_params)

    redirect_back fallback_location: root_path, **result.message
    log_info('Explore.create completed', { success: result.success?, repo_url: repo_url, connector_type: connector_type, object_type: params[:object_type], object_id: params[:object_id] })
  rescue => e
    log_error('Error processing Explore.create processor/action', { connector_type: connector_type, object_type: params[:object_type], object_id: params[:object_id] }, e)
    return redirect_back fallback_location: root_path, alert: I18n.t('explore.create.message_processor_error', connector_type: connector_type, object_type: params[:object_type], object_id: params[:object_id])
  end
end
