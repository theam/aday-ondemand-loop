require 'test_helper'

class Dataverse::Actions::DatasetFormTabsTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    @action = Dataverse::Actions::DatasetFormTabs.new
  end

  test 'edit returns tabs form partial' do
    @action.stubs(:datasets).returns([])
    @action.stubs(:subjects).returns([])
    @action.stubs(:profile).returns(nil)
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/dataverse/dataset_form_tabs', result.partial
  end

  test 'update not implemented' do
    assert_raises(NotImplementedError) { @action.update(@bundle, {}) }
  end
end
