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

  def redirect_url
    data[:redirect_url]
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
