# frozen_string_literal: true

module Events
  class ProjectCreated < BaseEvent
    def initialize(attributes = {})
      metadata = {
        'project_name' => attributes.delete(:project_name)
      }.compact
      super(attributes.merge(type: EventType::PROJECT_CREATED, metadata: metadata))
    end
  end
end
