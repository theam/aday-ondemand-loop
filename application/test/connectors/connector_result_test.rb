require 'test_helper'

class ConnectorResultTest < ActiveSupport::TestCase
  test 'defaults and accessors' do
    result = ConnectorResult.new({redirect_url: '/path', message: {notice: 'ok'}})
    assert_equal '/path', result.redirect_url
    assert_equal({notice: 'ok'}, result.message)
    assert result.success?
    assert result.redirect?
    assert_equal({redirect_url: '/path', message: {notice: 'ok'}}, result.to_h)
  end

  test 'success? false when success field set to false' do
    result = ConnectorResult.new(success: false)
    refute result.success?
  end

  test 'redirect_back flag helper' do
    result = ConnectorResult.new(redirect_back: true)
    assert result.redirect_back?
    refute result.redirect?
  end

  test 'resource_url returns stored URL' do
    result = ConnectorResult.new(resource_url: '/some/path')
    assert_equal '/some/path', result.resource_url
  end

  test 'resource_url is nil when missing' do
    result = ConnectorResult.new
    assert_nil result.resource_url
  end
end
