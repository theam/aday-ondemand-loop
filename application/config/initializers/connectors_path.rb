connectors_root = Rails.root.join("connectors")
return unless connectors_root.directory?

Dir.children(connectors_root).each do |connector|
  connector_path = connectors_root.join(connector)
  next unless connector_path.directory?

  %w[controllers models helpers services views javascript].each do |sub|
    sub_path = connector_path.join(sub)
    next unless sub_path.directory?

    Rails.autoloaders.main.push_dir(sub_path)
    Rails.application.config.eager_load_paths << sub_path

    case sub
    when "views"
      ActionController::Base.prepend_view_path(sub_path)
    when "helpers"
      if ActionController::Base.respond_to?(:helpers_path)
        ActionController::Base.helpers_path << sub_path
      end
    when "controllers"
      Rails.application.config.paths["app/controllers"] << sub_path
    when "models"
      Rails.application.config.paths["app/models"] << sub_path
    end
  end
end

