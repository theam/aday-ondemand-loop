require 'test_helper'

class DemoConnectorTest < ActiveSupport::TestCase
  test 'service uses translation' do
    assert_equal 'Hello from demo connector', Demo::ExampleService.new.greet
  end

  test 'view uses helper' do
    html = ApplicationController.render(template: 'demo/index')
    assert_includes html, 'helper works'
  end

  test 'model attr_accessor works' do
    model = Demo::ExampleModel.new
    model.name = 'Alice'
    assert_equal 'Alice', model.name
  end
end
