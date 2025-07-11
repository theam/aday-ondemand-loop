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
