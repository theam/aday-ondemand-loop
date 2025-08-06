require 'test_helper'

class Zenodo::ExploreConnectorProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Zenodo::ExploreConnectorProcessor.new
  end

  test 'show delegates to explorer without object id' do
    params = { connector_type: ConnectorType::ZENODO, object_type: :landing, query: 'q' }
    explorer = mock('explorer')
    ConnectorActionDispatcher.expects(:explorer).with(ConnectorType::ZENODO, :explorers, :landing).returns(explorer)
    explorer.expects(:show).with(params).returns(:result)
    assert_equal :result, @processor.show(params)
  end

  test 'create delegates to explorer with object id' do
    params = { connector_type: ConnectorType::ZENODO, object_type: :records, object_id: '2', project_id: '3', file_ids: ['f1'] }
    explorer = mock('explorer')
    ConnectorActionDispatcher.expects(:explorer).with(ConnectorType::ZENODO, :records, '2').returns(explorer)
    explorer.expects(:create).with(params).returns(:created)
    assert_equal :created, @processor.create(params)
  end
end
