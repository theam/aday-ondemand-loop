# frozen_string_literal: true

class ConnectorResult
  attr_reader :data

  def initialize(data = {})
    @data = data || {}
  end

  def message
    data[:message] || {}
  end

  def success?
    data[:success] != false
  end

  def resource
    data[:resource]
  end

  def resource_url
    return unless resource

    helpers = Rails.application.routes.url_helpers
    if resource.respond_to?(:project_id) && resource.respond_to?(:id)
      helpers.project_path(resource.project_id, anchor: "tab-link-#{resource.id}")
    else
      helpers.url_for(resource)
    end
  end

  def redirect_url
    data[:redirect_url]
  end

  def redirect?
    redirect_url.present?
  end

  def redirect_back?
    data[:redirect_back] == true
  end

  def template
    data[:template]
  end

  def locals
    data[:locals] || {}
  end

  def to_h
    data
  end
end
