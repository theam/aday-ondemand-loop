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

    connectors_root = config.root.join('connectors')
    if connectors_root.exist?
      Dir.children(connectors_root).each do |connector|
        connector_path = connectors_root.join(connector)
        next unless connector_path.directory?

        %w[models services processors helpers].each do |folder|
          path = connector_path.join(folder)
          next unless path.exist?

          path_str = path.to_s
          config.autoload_paths << path_str
          config.eager_load_paths << path_str
          config.paths['app/helpers'] << path_str if folder == 'helpers'
        end

        views_path = connector_path.join('views')
        config.paths['app/views'] << views_path.to_s if views_path.exist?

        locale_path = connector_path.join('locale')
        if locale_path.exist?
          config.i18n.load_path += Dir[locale_path.join('**', '*.{rb,yml,yaml}')]
        end
      end
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
