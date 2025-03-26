require "test_helper"

class Dataverse::DataverseServiceTest < ActiveSupport::TestCase

  def setup
    @tmp_dir = Dir.mktmpdir
    DownloadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
    @sample_uri = URI('https://example.com:443')
    @dataverse_metadata = Dataverse::DataverseMetadata.find_or_initialize_by_uri(@sample_uri)
    @service = Dataverse::DataverseService.new(@dataverse_metadata)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test "the class is initialized" do
    assert @service.kind_of?(Dataverse::DataverseService)
  end

  test "initialize download collection" do
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response.json'))
    dataset = Dataverse::DatasetResponse.new(valid_json)
    download_collection = @service.initialize_download_collection(dataset)
    assert download_collection.valid?
    assert download_collection.kind_of?(DownloadCollection)
    assert_equal 'dataverse', download_collection.type
  end
end