require 'test_helper'

class Dataverse::ExploreConnectorProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Dataverse::ExploreConnectorProcessor.new
  end

  test 'show delegates to explorer with object id' do
    params = { connector_type: ConnectorType::DATAVERSE, object_type: :collections, object_id: ':root', repo_url: :url }
    explorer = mock('explorer')
    ConnectorActionDispatcher.expects(:explorer).with(ConnectorType::DATAVERSE, :collections, ':root').returns(explorer)
    explorer.expects(:show).with(params).returns(:found)
    assert_equal :found, @processor.show(params)
  end

  test 'show delegates to dataset_versions explorer' do
    params = { connector_type: ConnectorType::DATAVERSE, object_type: :dataset_versions, object_id: 'pid', repo_url: :url }
    explorer = mock('explorer')
    ConnectorActionDispatcher.expects(:explorer).with(ConnectorType::DATAVERSE, :dataset_versions, 'pid').returns(explorer)
    explorer.expects(:show).with(params).returns(:ok)
    assert_equal :ok, @processor.show(params)
  end

  test 'create delegates to explorer with object id' do
    params = { connector_type: ConnectorType::DATAVERSE, object_type: :datasets, object_id: ':id', repo_url: :url }
    explorer = mock('explorer')
    ConnectorActionDispatcher.expects(:explorer).with(ConnectorType::DATAVERSE, :datasets, ':id').returns(explorer)
    explorer.expects(:create).with(params).returns(:created)
    assert_equal :created, @processor.create(params)
  end

  test 'params schema includes dataset params' do
    assert_includes @processor.params_schema, :page
    assert_includes @processor.params_schema, :query
    assert_includes @processor.params_schema, :project_id
    assert_includes @processor.params_schema, :version
    assert @processor.params_schema.any? { |p| p.is_a?(Hash) && p.key?(:file_ids) }
  end
end
