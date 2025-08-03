# frozen_string_literal: true
require 'test_helper'

class ConnectorActionDispatcherTest < ActiveSupport::TestCase
  test 'loads connector action for zenodo landing' do
    action = ConnectorActionDispatcher.load(ConnectorType::ZENODO, :actions, :landing)
    assert_instance_of Zenodo::Actions::Landing, action
  end

  test 'raises error for unknown action' do
    assert_raises(ConnectorActionDispatcher::ConnectorNotSupported) do
      ConnectorActionDispatcher.load(ConnectorType::ZENODO, :actions, :missing)
    end
  end
end
