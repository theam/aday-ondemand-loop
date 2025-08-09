require 'test_helper'

class Zenodo::ExploreConnectorProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Zenodo::ExploreConnectorProcessor.new
  end

  test 'show delegates to handler with object id' do
    params = { connector_type: ConnectorType::ZENODO, object_type: :records, object_id: '3', repo_url: :url }
    handler = mock('handler')
    ConnectorHandlerDispatcher.expects(:handler).with(ConnectorType::ZENODO, :records, '3').returns(handler)
    handler.expects(:show).with(params).returns(:found)
    assert_equal :found, @processor.show(params)
  end

  test 'create delegates to handler with object id' do
    params = { connector_type: ConnectorType::ZENODO, object_type: :records, object_id: '2', project_id: '3', file_ids: ['f1'] }
    handler = mock('handler')
    ConnectorHandlerDispatcher.expects(:handler).with(ConnectorType::ZENODO, :records, '2').returns(handler)
    handler.expects(:create).with(params).returns(:created)
    assert_equal :created, @processor.create(params)
  end
end
