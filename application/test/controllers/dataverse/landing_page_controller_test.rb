require 'test_helper'

class Dataverse::LandingPageControllerTest < ActionDispatch::IntegrationTest
  test 'index loads installations' do
    registry = mock('reg'); registry.stubs(:installations).returns([])
    DataverseHubRegistry.stubs(:registry).returns(registry)
    get view_dataverse_landing_url
    assert_response :success
  end
end
