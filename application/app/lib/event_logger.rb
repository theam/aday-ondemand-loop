# frozen_string_literal: true

module EventLogger
  def record_event(attributes)
    list = ProjectEventList.new(project_id: attributes[:project_id])
    event = list.add(attributes)
    if event
      LoggingCommon.log_info("Event saved", event.to_h)
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
