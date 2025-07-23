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
    first = @versions.versions.first
    assert_equal 340089, first.id
    assert_equal 'doi:10.70122/FK2/O9JYAO', first.dataset_persistent_id
  end
end

