# frozen_string_literal: true
require 'test_helper'

class ConnectorActionDispatcherTest < ActiveSupport::TestCase
  test 'loads connector action for zenodo landing' do
    action = ConnectorActionDispatcher.load(ConnectorType::ZENODO, :actions, :landing)
    assert_instance_of Zenodo::Actions::Landing, action
  end

  test 'passes object id to constructor for non-actions type' do
    module Zenodo::Actions
      class Dummy
        attr_reader :id

        def initialize(id)
          @id = id
        end
      end
    end

    action = ConnectorActionDispatcher.load(ConnectorType::ZENODO, :dummy, 123)
    assert_instance_of Zenodo::Actions::Dummy, action
    assert_equal 123, action.id
  ensure
    Zenodo::Actions.send(:remove_const, :Dummy)
  end

  test 'raises error for unknown action' do
    assert_raises(ConnectorActionDispatcher::ConnectorNotSupported) do
      ConnectorActionDispatcher.load(ConnectorType::ZENODO, :actions, :missing)
    end
  end
end
