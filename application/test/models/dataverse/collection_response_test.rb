require "test_helper"

class DataverseCollectionResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'collection_response', 'valid_response.json'))
    @response = DataverseCollectionResponse.new(valid_json)
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  test "valid json parses dataverse response" do
    assert_instance_of DataverseCollectionResponse, @response
    assert_equal "OK", @response.status
    assert_instance_of DataverseCollectionResponse::Data, @response.data
  end

  test "valid json parses :root dataverse response data" do
    data = @response.data
    assert_equal 1234, data.id
    assert_equal "Dataverse_Alias", data.alias
    assert_equal "Sample Dataverse", data.name
    assert_equal "Sample Dataverse description", data.description
    assert data.is_facet_root
    assert_empty data.parents
  end

  test "valid json parses child dataverse response data" do
    json = load_file_fixture(File.join('dataverse', 'collection_response', 'valid_child_response.json'))
    @child_response = DataverseCollectionResponse.new(json)
    data = @child_response.data
    assert_equal 1234, data.id
    assert_equal "Sample_Child_Dataverse", data.alias
    assert_equal "Sample child Dataverse", data.name
    assert_equal "Sample child dataverse for tests", data.description
    refute data.is_facet_root
    assert_equal 2, data.parents.size
    assert_equal "parent", data.parents.last[:identifier]
    assert_equal "Parent Dataverse", data.parents.last[:name]
    assert_equal "grandparent", data.parents.first[:identifier]
    assert_equal "Grandparent Dataverse", data.parents.first[:name]
  end

  test "dataverse response on empty json does not throw exception" do
    @invalid_response = DataverseCollectionResponse.new(empty_json)
    assert_instance_of DataverseCollectionResponse, @invalid_response
  end

  test "dataverse response with empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { DataverseCollectionResponse.new(empty_string) }
  end

end
