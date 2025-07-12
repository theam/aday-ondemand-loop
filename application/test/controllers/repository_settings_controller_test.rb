require "test_helper"
require 'tempfile'

class RepositorySettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tempfile = Tempfile.new('repo_db')
    RepoRegistry.repo_db = Repo::RepoDb.new(db_path: @tempfile.path)
    RepoRegistry.repo_db.set('demo.org', type: ConnectorType::DATAVERSE, metadata: {auth_key: 'old'})
  end

  def teardown
    @tempfile.unlink
  end

  test 'should get index' do
    get repository_settings_url
    assert_response :success
  end

  test 'should add repository on create' do
    resolver = mock('resolver')
    url_res = OpenStruct.new(type: ConnectorType::ZENODO, object_url: 'https://zenodo.org/', unknown?: false)
    resolver.stubs(:resolve).with('https://zenodo.org/').returns(url_res)
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    post repository_settings_url, params: { repo_url: 'https://zenodo.org/' }

    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.create.repo_added', type: 'zenodo'), flash[:notice]
    assert RepoRegistry.repo_db.get('zenodo.org')
  end

  test 'should show error on unknown repository' do
    resolver = mock('resolver')
    resolver.stubs(:resolve).with('u').returns(OpenStruct.new(unknown?: true))
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    post repository_settings_url, params: { repo_url: 'u' }

    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.create.invalid_repo', url: 'u'), flash[:alert]
  end

  test 'should update repository metadata' do
    put repository_setting_url('demo.org'), params: { metadata: {auth_key: 'new'} }
    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.update.repo_updated', domain: 'demo.org'), flash[:notice]
    assert_equal 'new', RepoRegistry.repo_db.get('demo.org').metadata.auth_key
  end

  test 'should show error when repository missing' do
    put repository_setting_url('missing.org'), params: { metadata: {auth_key: 'x'} }
    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.update.repo_not_found', domain: 'missing.org'), flash[:alert]
  end
end
