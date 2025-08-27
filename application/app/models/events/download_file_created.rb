# frozen_string_literal: true

module Events
  class DownloadFileCreated < BaseEvent
    def initialize(attributes = {})
      metadata = {
        'file_id' => attributes.delete(:file_id),
        'filename' => attributes.delete(:filename),
        'file_size' => attributes.delete(:file_size)
      }.compact
      super(attributes.merge(type: EventType::DOWNLOAD_FILE_CREATED, metadata: metadata))
    end
  end
end
