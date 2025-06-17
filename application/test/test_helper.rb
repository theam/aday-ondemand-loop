ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require_relative 'helpers/file_fixture_helper'
require_relative 'helpers/model_helper'

require_relative 'utils/download_files_provider_mock'
require_relative 'utils/http_mock'
require_relative 'utils/logging_common_mock'

require 'rails/test_help'
require 'mocha/minitest'
require 'axe/api'

# Configure axe-core API to run with WCAG level A rules by default.
# Change `wcag2a` to `wcag2aa` or `wcag2aaa` to audit against
# stricter accessibility standards.
Axe::API.configure do |config|
  config.options = { runOnly: { type: 'tag', values: ['wcag2a'] } }
  # To audit against stricter levels, replace `wcag2a` with `wcag2aa` or `wcag2aaa`.
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    #fixtures :all

    # Add more helper methods to be used by all tests here...
    include FileFixtureHelper
    include ModelHelper
  end
end
