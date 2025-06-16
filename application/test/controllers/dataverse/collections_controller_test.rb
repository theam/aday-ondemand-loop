require "test_helper"

class DataverseCollectionsControllerTest < ActionDispatch::IntegrationTest

  def setup
    dataverse_json = load_file_fixture(File.join('dataverse', 'collection_response', 'valid_response.json'))
    @dataverse = DataverseCollectionResponse.new(dataverse_json)
    search_json = load_file_fixture(File.join('dataverse', 'search_response', 'valid_response.json'))
    @search_response = DataverseSearchResponse.new(search_json, 1, 20)
  end

  test "should redirect to root path after not finding a dataverse" do
    DataverseCollectionService.any_instance.stubs(:find_collection_by_id).raises("error")
    DataverseCollectionService.any_instance.stubs(:search_collection_items).raises("error")
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse service error. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should redirect to root path after finding an unauthorized dataverse" do
    DataverseCollectionService.any_instance.stubs(:find_collection_by_id).returns(nil)
    DataverseCollectionService.any_instance.stubs(:search_collection_items).raises(DataverseCollectionService::UnauthorizedException)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse requires authorization. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should redirect to root path after not finding neither dataverse nor dataverse results" do
    DataverseCollectionService.any_instance.stubs(:find_collection_by_id).returns(nil)
    DataverseCollectionService.any_instance.stubs(:search_collection_items).returns(nil)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should redirect to root path after not finding dataverse response" do
    DataverseCollectionService.any_instance.stubs(:find_collection_by_id).returns(nil)
    DataverseCollectionService.any_instance.stubs(:search_collection_items).returns(@search_response)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should redirect to root path after not finding search response" do
    DataverseCollectionService.any_instance.stubs(:find_collection_by_id).returns(@dataverse)
    DataverseCollectionService.any_instance.stubs(:search_collection_items).returns(nil)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should display the datavers view with the results" do
    DataverseCollectionService.any_instance.stubs(:find_collection_by_id).returns(@dataverse)
    DataverseCollectionService.any_instance.stubs(:search_collection_items).returns(@search_response)
    get view_dataverse_url("example.com", ":root")
    assert_response :success
  end

end
