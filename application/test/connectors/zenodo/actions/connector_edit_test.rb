require 'test_helper'

class Zenodo::Actions::ConnectorEditTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    @bundle.stubs(:connector_metadata).returns(OpenStruct.new(server_domain: 'host'))
    @action = Zenodo::Actions::ConnectorEdit.new
  end

  test 'edit returns connector form' do
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/zenodo/connector_edit_form', result.partial
  end

  test 'update saves api key in repo' do
    RepoRegistry.repo_db.stubs(:update)
    result = @action.update(@bundle, {api_key: 'KEY', key_scope: 'server'})
    assert result.success?
  end
end
