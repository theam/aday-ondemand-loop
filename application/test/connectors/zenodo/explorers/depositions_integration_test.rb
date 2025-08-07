require 'test_helper'

class Zenodo::Explorers::DepositionsIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    RepoRegistry.repo_db = @repo_db
    @repo_db.set('https://zenodo.org', type: ConnectorType.get('zenodo'), metadata: { auth_key: 'KEY' })
    Project.stubs(:all).returns([])
    FileUtils.mkdir_p(Rails.root.join('app/assets/builds'))
    FileUtils.touch(Rails.root.join('app/assets/builds/application.css'))
  end

  test 'show deposition page through explore controller' do
    deposition = OpenStruct.new(
      id: '10',
      title: 'Deposition',
      draft?: false,
      description: 'Desc',
      publication_date: '2023-01-01',
      files: [OpenStruct.new(id: 'f1', filename: 'file1.txt', filesize: 1)]
    )
    service = mock('deposition_service')
    service.expects(:find_deposition).with('10').returns(deposition)
    Zenodo::DepositionService.expects(:new).with('https://zenodo.org', api_key: 'KEY').returns(service)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'depositions',
      object_id: '10'
    )

    assert_response :success
  end
end
