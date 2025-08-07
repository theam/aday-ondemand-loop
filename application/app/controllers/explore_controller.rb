class ExploreController < ApplicationController
  include LoggingCommon

  before_action :parse_connector_type
  before_action :build_repo_url, only: %i[show create]

  def landing
    processor = ConnectorClassDispatcher.explore_connector_processor(@connector_type)
    processor_params = params.permit(*processor.params_schema).to_h
    result = processor.landing(processor_params)

    unless result.success?
      log_error('Explore.landing action error', { connector_type: @connector_type, processor: processor.class.name }.merge(result.message))
      return redirect_to root_path, **result.message
    end

    render template: result.template, locals: result.locals
    log_info('Explore.landing completed', { connector_type: @connector_type })
  rescue => e
    log_error('Error processing Explore.landing processor/action', { connector_type: @connector_type }, e)
    return redirect_to root_path, alert: I18n.t('explore.landing.message_processor_error', connector_type: @connector_type)
  end

  def show
    processor = ConnectorClassDispatcher.explore_connector_processor(@connector_type)
    processor_params = params.permit(*processor.params_schema).to_h.merge(repo_url: @repo_url)
    result = processor.show(processor_params)

    unless result.success?
      log_error('Explore.show action error', { repo_url: @repo_url, connector_type: @connector_type, processor: processor.class.name, object_type: params[:object_type], object_id: params[:object_id] }.merge(result.message))
      return redirect_to root_path, **result.message
    end

    render template: result.template, locals: result.locals
    log_info('Explore.show completed', { repo_url: @repo_url, connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] })
  rescue => e
    log_error('Error processing Explore.show processor/action', { connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] }, e)
    return redirect_to root_path, alert: I18n.t('explore.show.message_processor_error', connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id])
  end

  def create
    processor = ConnectorClassDispatcher.explore_connector_processor(@connector_type)
    processor_params = params.permit(*processor.params_schema).to_h.merge(repo_url: @repo_url)
    result = processor.create(processor_params)

    redirect_back fallback_location: root_path, **result.message
    log_info('Explore.create completed', { success: result.success?, repo_url: @repo_url, connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] })
  rescue => e
    log_error('Error processing Explore.create processor/action', { connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] }, e)
    return redirect_back fallback_location: root_path, alert: I18n.t('explore.create.message_processor_error', connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id])
  end

  private

  def parse_connector_type
    @connector_type = ConnectorType.get(params[:connector_type])
  rescue ArgumentError => e
    log_error('Invalid connector type', { connector_type: params[:connector_type] }, e)
    redirect_to root_path, alert: I18n.t('explore.message_invalid_connector_type', connector_type: params[:connector_type])
  end

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
