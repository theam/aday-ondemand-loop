# frozen_string_literal: true

module Events
  class ProjectCreated < BaseEvent
    def initialize(attributes = {})
      metadata = {
        'name' => attributes.delete(:name),
        'download_dir' => attributes.delete(:download_dir),
      }.compact
      super(attributes.merge(type: EventType::PROJECT_CREATED, metadata: metadata))
    end
  end
end
