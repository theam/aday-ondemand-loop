# frozen_string_literal: true

module EventLogger
  def record_event(project_id:, entity_type:, entity_id:, message:, metadata:)
    attributes = {
      project_id: project_id,
      entity_type: entity_type,
      entity_id: entity_id,
      message: message,
      metadata: metadata
    }

    list = ProjectEventList.new(project_id: project_id)
    event = Event.new(**attributes)
    event_saved = list.add(event)
    if event_saved
      LoggingCommon.log_info("Event saved", event_saved.to_h)
      true
    else
      LoggingCommon.log_error('Cannot record event', { event: attributes })
      false
    end
  rescue => e
    LoggingCommon.log_error('Cannot record event', attributes, e)
    false
  end

  module_function :record_event
end
