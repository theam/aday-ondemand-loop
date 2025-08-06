require 'test_helper'

class ExploreControllerTest < ActionDispatch::IntegrationTest
  def stub_processor(action, result: nil, exception: nil)
    processor = mock('ExploreProcessor')
    processor.stubs(:params_schema).returns(%i[connector_type server_domain object_type object_id query server_scheme server_port])
    expectation = processor.expects(action).with(kind_of(Hash))
    expectation.returns(result) if result
    expectation.raises(exception) if exception
    ConnectorClassDispatcher.stubs(:explore_connector_processor).returns(processor)
  end

  test 'landing action renders template when processor succeeds' do
    stub_processor(:landing, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))

    get explore_landing_url(connector_type: 'zenodo')

    assert_response :success
  end

  test 'landing action redirects with message when processor fails' do
    stub_processor(:landing, result: ConnectorResult.new(message: { alert: 'error' }, success: false))

    get explore_landing_url(connector_type: 'zenodo')

    assert_redirected_to root_path
    assert_equal 'error', flash[:alert]
  end

  test 'landing action redirects with error message when processor raises' do
    stub_processor(:landing, exception: StandardError.new('boom'))

    get explore_landing_url(connector_type: 'zenodo')

    assert_redirected_to root_path
    assert_equal I18n.t('explore.landing.message_processor_error', connector_type: 'zenodo'), flash[:alert]
  end

  test 'redirects when repo url is invalid' do
    get '/explore/zenodo/%20/records/1'

    assert_redirected_to root_path
    assert_equal I18n.t('explore.show.message_invalid_repo_url', repo_url: ''), flash[:alert]
  end

  test 'show action renders template when processor succeeds' do
    stub_processor(:show, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_response :success
  end

  test 'show action redirects with message when processor fails' do
    stub_processor(:show, result: ConnectorResult.new(message: { alert: 'error' }, success: false))

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal 'error', flash[:alert]
  end

  test 'show action redirects with error message when processor raises' do
    stub_processor(:show, exception: StandardError.new('boom'))

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('explore.show.message_processor_error', connector_type: 'zenodo', object_type: 'records', object_id: '1'), flash[:alert]
  end

  test 'create action redirects with message from processor' do
    stub_processor(:create, result: ConnectorResult.new(message: { notice: 'ok' }, success: true))

    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal 'ok', flash[:notice]
  end

  test 'create action redirects with error message when processor raises' do
    stub_processor(:create, exception: StandardError.new('boom'))

    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('explore.create.message_processor_error', connector_type: 'zenodo', object_type: 'records', object_id: '1'), flash[:alert]
  end
end

