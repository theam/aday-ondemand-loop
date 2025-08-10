module ConnectorResponse
  extend ActiveSupport::Concern

  private

  def respond_success(result)
    if result.redirect?
      redirect_to result.redirect_url, **result.message
    elsif result.redirect_back?
      redirect_back fallback_location: root_path, **result.message
    elsif ajax_request?
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
    redirect_to root_path, alert: I18n.t("#{controller_name}.message_invalid_connector_type", connector_type: params[:connector_type])
  end
end
