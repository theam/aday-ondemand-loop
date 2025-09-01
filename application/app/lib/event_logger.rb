# frozen_string_literal: true

module EventLogger
  def record_event(attributes)
    event = Event.new(attributes)
    if event.save
      LoggingCommon.log_info("Event saved", event.to_h)
      true
    else
      LoggingCommon.log_error('Cannot record event', {event: event.to_h})
      event.errors.messages.each do |message|
        LoggingCommon.log_error(message)
      end
      false
    end
  rescue => e
    LoggingCommon.log_error('Cannot record event', { event: event.to_h }, e)
    false
  end

  module_function :record_event
end
