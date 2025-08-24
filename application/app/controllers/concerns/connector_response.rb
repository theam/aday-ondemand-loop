module ConnectorResponse
  extend ActiveSupport::Concern

  private

  def respond_success(result)
    if result.redirect?
      redirect_to result.redirect_url, **result.message
    elsif result.redirect_back?
      redirect_back fallback_location: root_path, **result.message
    elsif result.resource
      redirect_to resource_url(result.resource), **result.message
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

  def resource_url(resource)
    return nil unless resource

    if resource.respond_to?(:project_id) && resource.respond_to?(:id)
      project_path(id: resource.project_id, anchor: "tab-link-#{resource.id}")
    else
      url_for(resource)
    end
  end
end
