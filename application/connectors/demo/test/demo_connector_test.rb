require 'test_helper'

class DemoConnectorTest < ActiveSupport::TestCase
  test 'service uses translation' do
    assert_equal 'Hello from demo connector', Demo::ExampleService.new.greet
  end

  test 'view uses helper' do
    html = ApplicationController.render(template: 'demo/index')
    assert_includes html, 'helper works'
  end
end
