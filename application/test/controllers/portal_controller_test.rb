require "test_helper"

class PortalControllerTest < ActionDispatch::IntegrationTest
  def stub_action(result: nil, exception: nil)
    action = mock('PortalAction')
    action.stubs(:params_schema).returns(%i[])
    expectation = action.expects(:show).with(kind_of(Hash))
    expectation.returns(result) if result
    expectation.raises(exception) if exception
    ConnectorActionDispatcher.expects(:action).with(ConnectorType::DATAVERSE, 'landing').returns(action)
  end

  test 'handle renders template when action succeeds' do
    stub_action(result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))
    get portal_repo_url(connector_type: 'dataverse', action: 'landing')
    assert_response :success
  end

  test 'handle redirects with message when action fails' do
    stub_action(result: ConnectorResult.new(message: { alert: 'error' }, success: false))
    get portal_repo_url(connector_type: 'dataverse', action: 'landing')
    assert_redirected_to root_path
    assert_equal 'error', flash[:alert]
  end

  test 'handle redirects with error message when action raises' do
    stub_action(exception: StandardError.new('boom'))
    get portal_repo_url(connector_type: 'dataverse', action: 'landing')
    assert_redirected_to root_path
    assert_equal I18n.t('portal.handle.message_processor_error', connector_type: 'dataverse', action: 'landing'), flash[:alert]
  end

  test 'redirects when connector type is invalid' do
    get portal_repo_url(connector_type: 'bogus', action: 'landing')
    assert_redirected_to root_path
    assert_equal I18n.t('portal.message_invalid_connector_type', connector_type: 'bogus'), flash[:alert]
  end
end
