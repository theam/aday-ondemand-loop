require 'test_helper'

class Dataverse::ExploreConnectorProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Dataverse::ExploreConnectorProcessor.new
  end

  test 'landing delegates to landing explorer' do
    params = { connector_type: ConnectorType::DATAVERSE, page: 1, query: 'foo' }
    explorer = mock('explorer')
    Dataverse::Explorers::Landing.expects(:new).returns(explorer)
    explorer.expects(:show).with(params).returns(:ok)
    assert_equal :ok, @processor.landing(params)
  end

  test 'show delegates to explorer with object id' do
    params = { connector_type: ConnectorType::DATAVERSE, object_type: :collections, object_id: ':root', repo_url: :url }
    explorer = mock('explorer')
    ConnectorActionDispatcher.expects(:explorer).with(ConnectorType::DATAVERSE, :collections, ':root').returns(explorer)
    explorer.expects(:show).with(params).returns(:found)
    assert_equal :found, @processor.show(params)
  end

  test 'params schema includes landing params' do
    assert_includes @processor.params_schema, :page
    assert_includes @processor.params_schema, :query
  end
end
