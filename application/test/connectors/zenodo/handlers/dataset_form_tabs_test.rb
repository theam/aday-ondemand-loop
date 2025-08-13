require 'test_helper'

class Zenodo::Handlers::DatasetFormTabsTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    @action = Zenodo::Handlers::DatasetFormTabs.new
  end

  test 'params schema is empty' do
    assert_empty @action.params_schema
  end

  test 'edit returns tabs form partial' do
    @action.stubs(:depositions).returns([])
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/zenodo/dataset_form_tabs', result.template
  end

  test 'update not implemented' do
    assert_raises(NotImplementedError) { @action.update(@bundle, {}) }
  end

  test 'depositions fetched via user service' do
    meta = OpenStruct.new(zenodo_url: 'http://zen', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    service = mock('service')
    service.expects(:list_depositions).returns([1,2])
    Zenodo::UserService.expects(:new).with('http://zen', api_key: 'KEY').returns(service)
    assert_equal [1,2], @action.send(:depositions, @bundle)
  end
end
