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

class SimpleCov::Formatter::QuietFormatter
  def format(_result); end
end

SimpleCov.coverage_dir('tmp/coverage')

SimpleCov.start 'rails' do
  enable_coverage :branch
  add_filter '/test/'

  # Ensure coverage is captured for tests executed in forked workers
  enable_for_subprocesses true

  SimpleCov.formatter SimpleCov::Formatter::QuietFormatter
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

    @@lock = Mutex.new
    @@remaining_workers = 0

    parallelize_setup do |worker|
      @@lock.synchronize { @@remaining_workers += 1 }
      SimpleCov.command_name "test-#{worker}"
      SimpleCov.start
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
      @@lock.synchronize do
        @@remaining_workers -= 1
        SimpleCov::Formatter::HTMLFormatter.new.format(SimpleCov::ResultMerger.merged_result) if @@remaining_workers.zero?
      end
    end

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
