# frozen_string_literal: true

module Events
  class DownloadFileMessageLogged < BaseEvent
    def initialize(attributes = {})
      metadata = {
        'file_id' => attributes.delete(:file_id),
        'message' => attributes.delete(:message)
      }.compact
      super(attributes.merge(type: EventType::DOWNLOAD_FILE_MESSAGE_LOGGED, metadata: metadata))
    end
  end
end
