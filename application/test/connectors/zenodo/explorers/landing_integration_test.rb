require 'test_helper'

class Zenodo::Explorers::LandingIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    RepoRegistry.repo_db = @repo_db
    @repo_db.set('https://zenodo.org', type: ConnectorType.get('zenodo'))
    Project.stubs(:all).returns([])
    FileUtils.mkdir_p(Rails.root.join('app/assets/builds'))
    FileUtils.touch(Rails.root.join('app/assets/builds/application.css'))
  end

  test 'show landing page through explore controller' do
    Results = Struct.new(:items, :page, :first_page?, :last_page?, :prev_page, :next_page) do
      def to_s
        'results'
      end
    end
    results = Results.new([], 1, true, true, nil, nil)
    service = mock('search_service')
    service.expects(:search).with('query', page: 1).returns(results)
    Zenodo::SearchService.expects(:new).with('https://zenodo.org').returns(service)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'explorers',
      object_id: 'landing',
      query: 'query'
    )

    assert_response :success
  end
end
