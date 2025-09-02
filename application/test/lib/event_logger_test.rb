# frozen_string_literal: true
require 'test_helper'

class EventLoggerTest < ActiveSupport::TestCase
  test 'record_event builds event and adds it to list' do
    list = mock('ProjectEventList')
    ProjectEventList.expects(:new).with(project_id: '123').returns(list)

    event = mock('Event')
    Event.expects(:new).with(project_id: '123',
                             entity_type: 'project',
                             entity_id: '456',
                             message: 'events.project.test',
                             metadata: { 'foo' => 'bar' }).returns(event)

    list.expects(:add).with(event).returns(event)
    LoggingCommon.stubs(:log_info)

    assert EventLogger.record_event(project_id: '123',
                                    entity_type: 'project',
                                    entity_id: '456',
                                    message: 'events.project.test',
                                    metadata: { 'foo' => 'bar' })
  end
end
