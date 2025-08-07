require 'test_helper'

class Zenodo::Explorers::RecordsIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    RepoRegistry.repo_db = @repo_db
    @repo_db.set('https://zenodo.org', type: ConnectorType.get('zenodo'))
    Project.stubs(:all).returns([])
    FileUtils.mkdir_p(Rails.root.join('app/assets/builds'))
    FileUtils.touch(Rails.root.join('app/assets/builds/application.css'))
  end

  test 'show record page through explore controller' do
    record = OpenStruct.new(
      id: '123',
      title: 'Record',
      draft?: false,
      description: 'Desc',
      publication_date: '2023-01-01',
      files: [OpenStruct.new(id: 'f1', filename: 'file1.txt', filesize: 1)]
    )
    service = mock('record_service')
    service.expects(:find_record).with('123').returns(record)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'records',
      object_id: '123'
    )

    assert_response :success
  end
end
