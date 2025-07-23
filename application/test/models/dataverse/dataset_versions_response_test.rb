require "test_helper"

class Dataverse::DatasetVersionsResponseTest < ActiveSupport::TestCase
  def setup
    json = load_file_fixture(File.join('dataverse', 'dataset_versions_response', 'valid_response.json'))
    @versions = Dataverse::DatasetVersionsResponse.new(json)
  end

  test "valid json parses dataset versions" do
    assert_instance_of Dataverse::DatasetVersionsResponse, @versions
    assert_equal "OK", @versions.status
    assert_equal 2, @versions.versions.size
    assert_equal 1, @versions.versions.first.version_number
  end
end
