class ExploreController < ApplicationController
  include LoggingCommon

  before_action :parse_connector_type
  before_action :build_repo_url, only: %i[show create]

  def show
    processor = ConnectorClassDispatcher.explore_connector_processor(@connector_type)
    processor_params = params.permit(*processor.params_schema).to_h.merge(repo_url: @repo_url)
    result = processor.show(processor_params)

    unless result.success?
      log_error('Explore.show action error', { repo_url: @repo_url, connector_type: @connector_type, processor: processor.class.name, object_type: params[:object_type], object_id: params[:object_id] }.merge(result.message))
      return respond_error(result.message, root_path)
    end

    respond_success(result)
    log_info('Explore.show completed', { repo_url: @repo_url, connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] })
  rescue => e
    log_error('Error processing Explore.show processor/action', { connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id] }, e)
    respond_error({ alert: I18n.t('explore.show.message_processor_error', connector_type: @connector_type, object_type: params[:object_type], object_id: params[:object_id]) }, root_path)
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

  # --- Response helpers ---

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
