require 'test_helper'

class Zenodo::DownloadConnectorMetadataTest < ActiveSupport::TestCase
  def setup
    file = DownloadFile.new
    file.metadata = {record_id: 1}
    @meta = Zenodo::DownloadConnectorMetadata.new(file)
  end

  test 'repo_name is Zenodo' do
    assert_equal 'Zenodo', @meta.repo_name
  end

  test 'files_url uses record id' do
    assert_match '/records/1', @meta.files_url
  end
end
