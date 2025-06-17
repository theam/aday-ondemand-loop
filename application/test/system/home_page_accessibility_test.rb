require "application_system_test_case"

class HomePageAccessibilityTest < ApplicationSystemTestCase
  test "homepage is accessible" do
    visit root_path
    assert_accessible
  end
end
