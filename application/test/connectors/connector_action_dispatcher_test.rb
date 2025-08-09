# frozen_string_literal: true
require 'test_helper'

class ConnectorActionDispatcherTest < ActiveSupport::TestCase
  test 'loads connector action for zenodo connector_edit' do
    action = ConnectorActionDispatcher.action(ConnectorType::ZENODO, :connector_edit)
    assert_instance_of Zenodo::Actions::ConnectorEdit, action
  end

  test 'loads connector explorer for zenodo landing' do
    explorer = ConnectorActionDispatcher.explorer(ConnectorType::ZENODO, :explorers, :landing)
    assert_instance_of Zenodo::Explorers::Landing, explorer
  end

  test 'passes object id to explorer constructor for non-explorers type' do
    module Zenodo::Explorers
      class Dummy
        attr_reader :id

        def initialize(id)
          @id = id
        end
      end
    end

    explorer = ConnectorActionDispatcher.explorer(ConnectorType::ZENODO, :dummy, 456)
    assert_instance_of Zenodo::Explorers::Dummy, explorer
    assert_equal 456, explorer.id
  ensure
    Zenodo::Explorers.send(:remove_const, :Dummy)
  end

  test 'raises error for unknown action or explorer' do
    assert_raises(ConnectorActionDispatcher::ConnectorNotSupported) do
      ConnectorActionDispatcher.action(ConnectorType::ZENODO, :missing)
    end
    assert_raises(ConnectorActionDispatcher::ConnectorNotSupported) do
      ConnectorActionDispatcher.explorer(ConnectorType::ZENODO, :explorers, :missing)
    end
  end
end
