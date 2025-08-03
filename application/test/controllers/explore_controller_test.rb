require "test_helper"

class ExploreControllerTest < ActionDispatch::IntegrationTest
  test 'should render placeholder template with notice' do
    get explore_url(
      connector_type: 'dataverse',
      server_domain: 'dataverse.harvard.edu',
      object_type: 'dataverse',
      object_id: 'harvard'
    )

    assert_response :success
    assert_select 'div.alert-info'
    assert_equal I18n.t('explore.show.message_success'), flash.now[:notice]
  end

  test 'zenodo landing action delegates to search service' do
    service = mock
    service.expects(:search)
           .with('test', page: 1, per_page: 10)
           .returns(OpenStruct.new(items: []))
    Zenodo::SearchService.expects(:new)
                          .with('https://zenodo.org')
                          .returns(service)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'actions',
      object_id: 'landing',
      query: 'test'
    )

    assert_response :success
  end

  test 'redirects when repo url is invalid' do
    get '/explore/zenodo/%20/actions/landing'

    assert_redirected_to root_path
    assert_equal I18n.t('explore.show.message_invalid_repo_url'), flash[:alert]
  end
end
