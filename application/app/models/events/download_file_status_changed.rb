# frozen_string_literal: true

module Events
  class DownloadFileStatusChanged < BaseEvent
    def initialize(attributes = {})
      metadata = {
        'file_id' => attributes.delete(:file_id),
        'previous_status' => attributes.delete(:previous_status),
        'new_status' => attributes.delete(:new_status)
      }.compact
      super(attributes.merge(type: EventType::DOWNLOAD_FILE_STATUS_CHANGED, metadata: metadata))
    end
  end
end
