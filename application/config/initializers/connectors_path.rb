connectors_root = Rails.root.join('connectors')
if connectors_root.directory?
  Dir.children(connectors_root).each do |connector|
    connector_path = connectors_root.join(connector)
    next unless connector_path.directory?

    %w[controllers models helpers services views javascript].each do |sub|
      sub_path = connector_path.join(sub)
      next unless sub_path.directory?

      case sub
      when 'controllers'
        Rails.application.config.paths['app/controllers'] << sub_path
      when 'models'
        Rails.application.config.paths['app/models'] << sub_path
      when 'helpers'
        Rails.application.config.paths['app/helpers'] << sub_path
      when 'views'
        Rails.application.config.paths['app/views'] << sub_path
      else
        ActiveSupport::Dependencies.autoload_paths << sub_path
      end
    end
  end
end
