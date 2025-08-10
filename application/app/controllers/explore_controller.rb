class ExploreController < ApplicationController
  include LoggingCommon
  include ConnectorResponse

  before_action :parse_connector_type
  before_action :build_repo_url, only: %i[show create]

  def show
    handler = ConnectorHandlerDispatcher.handler(@connector_type, params[:object_type], params[:object_id])
    handler_params = params.permit(*handler.params_schema).to_h.merge(repo_url: @repo_url)
    result = handler.show(handler_params)

    unless result.success?
      log_error('Explore.show action error', { repo_url: @repo_url, connector_type: @connector_type, handler: handler.class.name, object_type: params[:object_type], object_id: params[:object_id] }.merge(result.message))
      return respond_error(result.message, root_path)
    end

    respond_success(result)
    log_info('Explore.show completed', { repo_url: @repo_url, connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] })
  rescue => e
    log_error('Error processing Explore.show handler/action', { connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] }, e)
    respond_error({ alert: I18n.t('explore.show.message_processor_error', connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id]) }, root_path)
  end

  def create
    handler = ConnectorHandlerDispatcher.handler(@connector_type, params[:object_type], params[:object_id])
    handler_params = params.permit(*handler.params_schema).to_h.merge(repo_url: @repo_url)
    result = handler.create(handler_params)

    redirect_back fallback_location: root_path, **result.message
    log_info('Explore.create completed', { success: result.success?, repo_url: @repo_url, connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] })
  rescue => e
    log_error('Error processing Explore.create handler/action', { connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] }, e)
    return redirect_back fallback_location: root_path, alert: I18n.t('explore.create.message_processor_error', connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id])
  end

  private

  def build_repo_url
    @repo_url = Repo::RepoUrl.build(
      params[:server_domain],
      scheme: params[:server_scheme],
      port: params[:server_port]
    )

    if @repo_url.nil?
      redirect_to root_path, alert: I18n.t("explore.#{action_name}.message_invalid_repo_url", repo_url: '')
      return
    end

    repo_info = RepoRegistry.repo_db.get(@repo_url.server_url)
    if repo_info.nil? || repo_info.type != @connector_type
      redirect_to root_path, alert: I18n.t("explore.#{action_name}.message_invalid_repo_url", repo_url: @repo_url.to_s)
      return
    end
  end
end
