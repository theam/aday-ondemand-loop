require "test_helper"

class ExploreControllerTest < ActionDispatch::IntegrationTest
  def setup
    @repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    RepoRegistry.repo_db = @repo_db
  end

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

  test 'landing action renders partial when processor succeeds via ajax request' do
    stub_processor(:landing, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))

    get explore_landing_url(connector_type: 'zenodo'), xhr: true

    assert_response :success
  end

  test 'landing action redirects with message when processor fails' do
    stub_processor(:landing, result: ConnectorResult.new(message: { alert: 'error' }, success: false))

    get explore_landing_url(connector_type: 'zenodo')

    assert_redirected_to root_path
    assert_equal 'error', flash[:alert]
  end

  test 'landing action renders flash messages when processor fails via ajax request' do
    stub_processor(:landing, result: ConnectorResult.new(message: { alert: 'error' }, success: false))

    get explore_landing_url(connector_type: 'zenodo'), xhr: true

    assert_response :internal_server_error
    assert_includes @response.body, 'error'
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

  test 'redirects when connector type is invalid' do
    get explore_landing_url(connector_type: 'bogus')

    assert_redirected_to root_path
    assert_equal I18n.t('explore.message_invalid_connector_type', connector_type: 'bogus'), flash[:alert]
  end

  test 'show action renders template when processor succeeds' do
    stub_processor(:show, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))
    @repo_db.set('https://example.org', type: ConnectorType.get('zenodo'))

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_response :success
  end

  test 'show action renders partial when processor succeeds via ajax request' do
    stub_processor(:show, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))
    @repo_db.set('https://example.org', type: ConnectorType.get('zenodo'))

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    ), xhr: true

    assert_response :success
  end

  test 'show action redirects with message when processor fails' do
    stub_processor(:show, result: ConnectorResult.new(message: { alert: 'error' }, success: false))
    @repo_db.set('https://example.org', type: ConnectorType.get('zenodo'))

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal 'error', flash[:alert]
  end

  test 'show action renders flash messages when processor fails via ajax request' do
    stub_processor(:show, result: ConnectorResult.new(message: { alert: 'error' }, success: false))
    @repo_db.set('https://example.org', type: ConnectorType.get('zenodo'))

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    ), xhr: true

    assert_response :internal_server_error
    assert_includes @response.body, 'error'
  end

  test 'show action redirects with error message when processor raises' do
    stub_processor(:show, exception: StandardError.new('boom'))
    @repo_db.set('https://example.org', type: ConnectorType.get('zenodo'))

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
    @repo_db.set('https://example.org', type: ConnectorType.get('zenodo'))

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
    @repo_db.set('https://example.org', type: ConnectorType.get('zenodo'))

    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('explore.create.message_processor_error', connector_type: 'zenodo', object_type: 'records', object_id: '1'), flash[:alert]
  end

  test 'show action redirects when repo url not in repo db' do
    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'missing.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('explore.show.message_invalid_repo_url', repo_url: 'https://missing.org/'), flash[:alert]
  end

  test 'create action redirects when repo url not in repo db' do
    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'missing.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('explore.create.message_invalid_repo_url', repo_url: 'https://missing.org/'), flash[:alert]
  end
end

