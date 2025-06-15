require "test_helper"

class DataverseCreateDatasetResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'create_dataset_response', 'valid_response.json'))
    @response = DataverseCreateDatasetResponse.new(valid_json)
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  test "valid json parses create dataset response" do
    assert_instance_of DataverseCreateDatasetResponse, @response
    assert_equal "OK", @response.status
  end

  test "valid json parses valid persistent id and id" do
    assert_equal 1, @response.id
    assert_equal "doi:10.70122/FK2/GV5L9W", @response.persistent_id
  end

  test "create dataset response on empty json does not throw exception" do
    @invalid_response = DataverseCreateDatasetResponse.new(empty_json)
    assert_instance_of DataverseCreateDatasetResponse, @invalid_response
    assert_nil @invalid_response.persistent_id
  end

  test "create dataset response with empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { DataverseCreateDatasetResponse.new(empty_string) }
  end

end
