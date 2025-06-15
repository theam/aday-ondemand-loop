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
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    connectors_root = Rails.root.join("connectors")

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
  end
end
