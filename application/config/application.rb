require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Libraries required by the Loop App
require 'ostruct'

module DataverseForOndemand
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # ALLOW ANY DOMAINS
    config.hosts.clear

    # Load connector plugin folders
    connectors_root = Rails.root.join('connectors')
    Dir.glob(connectors_root.join('*')).select { |f| File.directory?(f) }.each do |connector_dir|
      connector_name = File.basename(connector_dir).camelize
      unless Object.const_defined?(connector_name)
        Object.const_set(connector_name, Module.new)
      end
      namespace_mod = Object.const_get(connector_name)

      %w[controllers models services].each do |folder|
        path = File.join(connector_dir, folder)
        if Dir.exist?(path)
          Rails.autoloaders.main.push_dir(path, namespace: namespace_mod)
        end
      end

      helpers_path = File.join(connector_dir, 'helpers')
      if Dir.exist?(helpers_path)
        Rails.autoloaders.main.push_dir(helpers_path, namespace: namespace_mod)
        config.paths['app/helpers'] << helpers_path
      end

      views_path = File.join(connector_dir, 'views')
      config.paths['app/views'] << views_path if Dir.exist?(views_path)
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
