ENV['RAILS_ENV'] ||= 'test'

# THIS IS FOR DEBUGGING CI RANDOM ERRORS:
# ArgumentError: `secret_key_base` for test environment must be a type of String`
at_exit do
  if $!
    puts "\n=== Uncaught Exception at Exit ==="
    puts $!.class
    puts $!.message
    puts $!.backtrace.join("\n")
    puts "=== END Uncaught Exception ===\n\n"
  end
end

# TEST COVERAGE SETUP
require 'simplecov'

SimpleCov.coverage_dir('tmp/coverage')

SimpleCov.start 'rails' do
  enable_coverage :branch
  add_filter '/test/'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
  ]
end

# Disable SimpleCov's default at_exit so we can safely handle coverage after
# Minitest finishes in each parallel worker.
SimpleCov.at_exit {}

Minitest.after_run do
  SimpleCov.command_name "test-#{Process.pid}"
  SimpleCov.result.format!
end

require_relative '../config/environment'
require_relative 'utils/file_fixture_helper'
require_relative 'utils/model_helper'
require_relative 'utils/zenodo_helper'
require_relative 'utils/dataverse_helper'

require_relative 'utils/download_files_provider_mock'
require_relative 'utils/http_mock'
require_relative 'utils/logging_common_mock'

require 'rails/test_help'
require 'mocha/minitest'

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    # Add more helper methods to be used by all tests here...
    include FileFixtureHelper
    include ModelHelper
    include ZenodoHelper
    include DataverseHelper

    setup do
      begin
        Rails.application.secret_key_base ||= 'a_secure_dummy_key_for_tests'
        # THIS IS FOR DEBUGGING CI RANDOM ERRORS:
        # ArgumentError: `secret_key_base` for test environment must be a type of String`
      rescue ArgumentError => e
        puts "\n=== secret_key_base ArgumentError caught ==="
        puts e.message
        puts e.backtrace.join("\n")
        puts "=== END secret_key_base trace ===\n\n"
        raise e
      end
    end
  end
end
