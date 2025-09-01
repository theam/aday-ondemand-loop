# frozen_string_literal: true

class ProjectEventList
  include YamlStorageCommon

  class Event
    include ActiveModel::Model

    ATTRIBUTES = %w[id project_id message entity_type entity_id creation_date metadata].freeze

    attr_accessor(*ATTRIBUTES)

    validates_presence_of :id, :project_id, :message, :entity_type, :creation_date

    def initialize(attributes = {})
      super
      self.id = SecureRandom.uuid.to_s if id.blank?
      self.creation_date ||= DateTimeCommon.now
      self.metadata ||= {}
    end

    def to_h
      ATTRIBUTES.each_with_object({}) do |attr, hash|
        hash[attr.to_s] = public_send(attr)
      end
    end

    def self.from_hash(data)
      new.tap do |instance|
        ATTRIBUTES.each do |attr|
          instance.public_send("#{attr}=", data[attr.to_s])
        end
      end
    end
  end

  def initialize(project_id:)
    @project_id = project_id
    @events = load_events
  end

  def all
    @events
  end

  def add(attributes)
    attrs = attributes.merge(project_id: @project_id)
    event = attributes.is_a?(Event) ? attributes : Event.new(attrs)
    return false unless event.valid?

    @events << event
    store
    event
  end

  private

  def load_events
    path = Project.events_file(@project_id)
    data = self.class.load_from_file(path) || []
    data.select { |attrs| attrs.is_a?(Hash) }.map { |attrs| Event.from_hash(attrs) }
  rescue => e
    LoggingCommon.log_error('Cannot load events', { file: path }, e)
    []
  end

  def to_yaml
    @events.map(&:to_h).to_yaml
  end

  def store
    store_to_file(Project.events_file(@project_id))
  end
end
