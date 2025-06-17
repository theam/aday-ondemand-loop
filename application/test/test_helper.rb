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

# Default Axe rules enforce WCAG level A. Replace `wcag2a` with `wcag2aa` or
# `wcag2aaa` below for stricter conformance.
AXE_OPTIONS = {
  runOnly: {
    type: 'tag',
    values: ['wcag2a']
  }
}

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
