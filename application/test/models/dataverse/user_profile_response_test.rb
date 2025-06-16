require "test_helper"

class DataverseUserProfileResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'user_profile_response', 'valid_response.json'))
    @response = DataverseUserProfileResponse.new(valid_json)
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  test "valid json parses user profile response" do
    assert_instance_of DataverseUserProfileResponse, @response
    assert_equal "OK", @response.status
    assert_equal "@johndoe", @response.identifier
    assert_equal "John Doe", @response.display_name
    assert_equal "John", @response.first_name
    assert_equal "Doe", @response.last_name
    assert_equal "johndoe@example.com", @response.email
    assert_equal false, @response.superuser
    assert_equal false, @response.deactivated
    assert_equal "johndoe", @response.persistent_user_id
  end

  test "user profile response on empty json does not throw exception" do
    @invalid_response = DataverseUserProfileResponse.new(empty_json)
    assert_instance_of DataverseUserProfileResponse, @invalid_response
  end

  test "user profile response with empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { DataverseUserProfileResponse.new(empty_string) }
  end

end
