# frozen_string_literal: true

# Class to dynamically load connector actions.
# Builds a class name based on connector_type, object_type and object_id
# and instantiates the corresponding action class.
class ConnectorActionDispatcher
  def self.load(connector_type, object_type, object_id)
    module_name = connector_type.to_s.camelize
    object_module = 'Actions'

    if object_type.to_s == 'actions'
      class_name = object_id.to_s.camelize
      connector_class = "#{module_name}::#{object_module}::#{class_name}"
      connector_class.constantize.new
    else
      class_name = object_type.to_s.camelize
      connector_class = "#{module_name}::#{object_module}::#{class_name}"
      connector_class.constantize.new(object_id)
    end
  rescue NameError
    raise ConnectorNotSupported, "Invalid connector action #{connector_class}"
  end

  class ConnectorNotSupported < StandardError; end
end
