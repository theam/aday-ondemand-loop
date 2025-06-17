require "test_helper"
require "axe/minitest"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Axe::Assertions
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
