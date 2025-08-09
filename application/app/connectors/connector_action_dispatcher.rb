# frozen_string_literal: true

# Class to dynamically load connector actions or explorers.
# Builds a class name based on connector_type, object_type and object_id
# and instantiates the corresponding class.
class ConnectorActionDispatcher
  def self.action(connector_type, action)
    module_name = connector_type.to_s.camelize
    class_name = action.to_s.camelize
    connector_class = "#{module_name}::Actions::#{class_name}"
    connector_class.constantize.new
  rescue NameError
    raise ConnectorNotSupported, "Invalid connector action #{connector_class}"
  end

  def self.explorer(connector_type, object_type, object_id)
    load_from_module(connector_type, object_type, object_id, 'Explorers')
  end

  def self.load_from_module(connector_type, object_type, object_id, object_module)
    module_name = connector_type.to_s.camelize

    if object_type.to_s == object_module.downcase
      class_name = object_id.to_s.camelize
      connector_class = "#{module_name}::#{object_module}::#{class_name}"
      connector_class.constantize.new
    else
      class_name = object_type.to_s.camelize
      connector_class = "#{module_name}::#{object_module}::#{class_name}"
      connector_class.constantize.new(object_id)
    end
  rescue NameError
    raise ConnectorNotSupported, "Invalid connector #{object_module.singularize.downcase} #{connector_class}"
  end

  private_class_method :load_from_module

  class ConnectorNotSupported < StandardError; end
end
