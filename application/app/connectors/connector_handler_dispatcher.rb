# frozen_string_literal: true

class ConnectorHandlerDispatcher
  # Dynamically loads a connector handler class based on the connector type and
  # object type. If an object_id is provided it will be passed to the handler's
  # constructor, otherwise the handler will be instantiated without arguments.
  def self.handler(connector_type, object_type, object_id = nil)
    module_name = connector_type.to_s.camelize
    class_name = object_type.to_s.camelize
    connector_class = "#{module_name}::Handlers::#{class_name}"

    object_id.nil? ? connector_class.constantize.new : connector_class.constantize.new(object_id)
  rescue NameError
    raise ConnectorNotSupported, "Invalid connector handler #{connector_class}"
  end

  class ConnectorNotSupported < StandardError; end
end

