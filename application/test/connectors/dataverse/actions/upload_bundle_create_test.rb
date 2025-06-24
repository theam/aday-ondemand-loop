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

  test 'create handles dataset url' do
    url_data = OpenStruct.new(collection?: false, dataset?: true, dataverse_url: 'http://dv.org', domain: 'dv.org', dataset_id: 'DS1')
    Dataverse::DataverseUrl.stubs(:parse).returns(url_data)

    service = mock('service')
    ds = mock('ds')
    ds.stubs(:data).returns(OpenStruct.new(parents: [{name: 'root'}, {name: 'col', identifier: 'c1'}]))
    ds.stubs(:metadata_field).with('title').returns('Dataset Title')
    service.expects(:find_dataset_version_by_persistent_id).with('DS1').returns(ds)
    Dataverse::DatasetService.stubs(:new).returns(service)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)
    result = @action.create(@project, object_url: 'http://dv.org/datasets/DS1')
    assert result.success?
    assert_equal 'Dataset Title', result.resource.metadata[:dataset_title]
  end
end
