require 'test_helper'

class Zenodo::Actions::UploadBundleCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Zenodo::Actions::UploadBundleCreate.new
  end

  test 'url not deposition returns error' do
    result = @action.create(@project, object_url: 'http://example.com')
    refute result.success?
  end
end
