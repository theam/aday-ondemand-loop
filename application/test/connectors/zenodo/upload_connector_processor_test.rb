require 'test_helper'
require_relative '../../helpers/zenodo_helper'

class Zenodo::UploadConnectorProcessorTest < ActiveSupport::TestCase
  include ModelHelper
  include ZenodoHelper

  def setup
    @project = create_project
    @bundle = create_upload_bundle(@project)
    @file = create_upload_file(@project, @bundle)
    @bundle.stubs(:connector_metadata).returns(OpenStruct.new(bucket_url: nil, api_key: OpenStruct.new(value: 'KEY')))
    @processor = Zenodo::UploadConnectorProcessor.new(@file)
  end

  test 'upload returns error when bucket_url missing' do
    result = @processor.upload
    assert_equal FileStatus::ERROR, result.status
    assert_match 'Missing bucket URL', result.message
  end

  test 'process handles cancel and status' do
    # Prepare metadata with bucket_url so upload works
    meta = OpenStruct.new(bucket_url: 'https://bucket', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    @processor = Zenodo::UploadConnectorProcessor.new(@file)

    Zenodo::ZenodoBucketHttpUploader.any_instance.stubs(:upload).yields({total:1, uploaded:1})

    @processor.upload
    request = OpenStruct.new(command: 'upload.status', body: OpenStruct.new(file_id: @file.id))
    status = @processor.process(request)
    assert_equal({message: 'upload in progress', status: {total:1, uploaded:1}}, status)

    cancel_req = OpenStruct.new(command: 'upload.cancel', body: OpenStruct.new(file_id: @file.id))
    cancel_result = @processor.process(cancel_req)
    assert_equal true, @processor.cancelled
    assert_equal 'cancellation requested', cancel_result[:message]
  end
end
