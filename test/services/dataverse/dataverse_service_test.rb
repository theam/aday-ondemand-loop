require "test_helper"

class Dataverse::DataverseServiceTest < ActiveSupport::TestCase

  def setup
    @tmp_dir = Dir.mktmpdir
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
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

  test "initialize download files" do
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response.json'))
    dataset = Dataverse::DatasetResponse.new(valid_json)
    download_collection = @service.initialize_download_collection(dataset)
    assert download_collection.save
    download_files = @service.initialize_download_files(download_collection, dataset, [7])
    assert download_files.kind_of?(Array)
    assert_equal 1, download_files.count
    assert download_files[0].kind_of?(DownloadFile)
    assert download_files[0].valid?
    assert_equal 'dataverse', download_files[0].type
    assert_equal download_collection.id, download_files[0].collection_id
    assert_equal download_collection.metadata_id, download_files[0].metadata_id
    assert_equal 'ready', download_files[0].status
    assert_equal 272314, download_files[0].size
    assert_equal "screenshot.png", download_files[0].filename
    assert_equal "13035cba04a51f54dd8101fe726cda5c", download_files[0].checksum
    assert_equal "image/png", download_files[0].content_type
  end
end