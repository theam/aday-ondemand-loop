require 'test_helper'

class Dataverse::UploadBundleConnectorMetadataTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @bundle = create_upload_bundle(@project)
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      collection_title: 'My Collection',
      dataset_title: nil,
      collection_id: 'COL1',
      dataset_id: nil,
      auth_key: 'KEY'
    }
    @meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
  end

  test 'server_domain parsed from url' do
    assert_equal 'demo.dataverse.org', @meta.server_domain
  end

  test 'api_key detected' do
    assert @meta.api_key?
  end

  test 'to_h converts keys to strings' do
    assert_equal 'My Collection', @meta.to_h['collection_title']
  end
end
