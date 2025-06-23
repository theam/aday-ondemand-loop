require 'test_helper'

class Dataverse::Actions::UploadBundleCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Dataverse::Actions::UploadBundleCreate.new
  end

  test 'error on unsupported url' do
    Dataverse::DataverseUrl.stubs(:parse).returns(OpenStruct.new(collection?: false, dataset?: false, dataverse_url: 'http://dv.org', domain: 'dv.org'))
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: OpenStruct.new(data: OpenStruct.new(name: 'root'))))
    result = @action.create(@project, object_url: 'http://example.com')
    assert result.success?
  end
end
