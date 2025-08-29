# frozen_string_literal: true

class Event < ApplicationDiskRecord
  include ActiveModel::Model

  TYPES = %w[
    project_created
    project_updated
  ].freeze

  TYPES.each do |type|
    const_set(type.upcase, type)
  end

  ENTITY_TYPES = %w[project download_file upload_bundle upload_file].freeze
  ATTRIBUTES = %w[id project_id type entity_type entity_id creation_date metadata].freeze

  attr_accessor(*ATTRIBUTES)

  validates_presence_of :id, :project_id, :type, :entity_type, :creation_date

  def initialize(attributes = {})
    super
    self.id ||= self.class.generate_id
    self.creation_date ||= DateTimeCommon.now
    self.metadata ||= {}
  end

  def self.for_project(project_id)
    path = Project.events_file(project_id)
    return [] unless File.exist?(path)
    data = YAML.safe_load(File.read(path), permitted_classes: [Hash], aliases: true) || []
    data = [data] if data.is_a?(Hash)
    data.select { |attrs| attrs.is_a?(Hash) }.map { |attrs| load_from_hash(attrs) }
  rescue => e
    LoggingCommon.log_error("Cannot load events", { file: path }, e)
    []
  end

  def save
    return false unless valid?

    events = self.class.for_project(project_id)
    events << self
    self.class.store_events(project_id, events)
  end

  private

  def self.load_from_hash(data)
    new.tap do |instance|
      ATTRIBUTES.each do |attr|
        value = data[attr.to_s]
        instance.public_send("#{attr}=", value)
      end
    end
  end

  def self.store_events(project_id, events)
    path = Project.events_file(project_id)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |f| f.write(events.map(&:to_h).to_yaml) }
    true
  rescue => e
    LoggingCommon.log_error("Cannot store events", { file: path }, e)
    false
  end
end
