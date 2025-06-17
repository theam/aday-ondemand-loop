require "test_helper"
require "axe/api"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  private

  def assert_accessible(**options)
    analyzer = Axe::API.new(page, **options)
    result = analyzer.analyze
    violations = result["violations"] || result.violations
    assert violations.empty?, "Accessibility violations:\n#{format_violations(violations)}"
  end

  def format_violations(violations)
    violations.map { |v| "#{v['id']}: #{v['help']}" }.join("\n")
  end
end
