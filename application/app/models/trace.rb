# frozen_string_literal: true

class Trace < ApplicationDiskRecord
  include ActiveModel::Model
  include DateTimeCommon

  ATTRIBUTES = %w[id entity_type entity_ids creation_date message].freeze

  attr_accessor(*ATTRIBUTES)

  validates_presence_of :id, :entity_type, :creation_date, :message

  def self.add(entity_type:, entity_ids:, message:)
    entity_ids = Array(entity_ids)
    trace = new(
      id: generate_id,
      entity_type: entity_type.to_s,
      entity_ids: entity_ids,
      creation_date: DateTimeCommon.now,
      message: message
    )
    trace.save(entity_ids.first)
    trace
  end

  def self.record(entity, message)
    info = parse_entity(entity)
    add(entity_type: info[:entity_type], entity_ids: info[:ids], message: message)
  end

  def save(project_id)
    return false unless valid?

    file = self.class.project_file(project_id)
    traces = self.class.load_all_from_file(file)
    traces << to_h.deep_stringify_keys
    ensure_storage_directory!(file)
    File.open(file, 'w') { |f| f.write(traces.to_yaml) }
    true
  end

  def self.all(entity_type = nil, entity_ids = [])
    if entity_type.nil?
      project_files.flat_map { |f| load_all_from_file(f).map { |h| from_hash(h) } }
                  .sort_by { |t| -DateTimeCommon.to_time(t.creation_date).to_f }
    else
      project_id = Array(entity_ids).first
      traces = load_all_from_file(project_file(project_id)).map { |h| from_hash(h) }
      traces.select! { |t| t.entity_type == entity_type }
      traces.select! { |t| t.entity_ids == Array(entity_ids) } if entity_ids.any?
      traces.sort_by { |t| -DateTimeCommon.to_time(t.creation_date).to_f }
    end
  end

  def self.find(entity_type, entity_ids, trace_id)
    project_id = Array(entity_ids).first
    traces = load_all_from_file(project_file(project_id)).map { |h| from_hash(h) }
    traces.find { |t| t.id == trace_id && t.entity_type == entity_type && t.entity_ids == Array(entity_ids) }
  end

  def self.project_file(project_id)
    File.join(Project.project_metadata_dir(project_id), 'traces.yml')
  end

  def self.project_files
    Dir.glob(File.join(Project.metadata_directory, '*', 'traces.yml'))
  end

  def self.load_all_from_file(file)
    return [] unless File.exist?(file)

    data = YAML.safe_load(File.read(file), permitted_classes: [Hash])
    data.is_a?(Array) ? data : []
  rescue StandardError
    []
  end

  def self.from_hash(hash)
    new.tap do |t|
      ATTRIBUTES.each { |attr| t.public_send("#{attr}=", hash[attr.to_s]) }
    end
  end
  def self.parse_entity(entity)
    case entity
    when Project
      { entity_type: 'project', ids: [entity.id] }
    when DownloadFile
      { entity_type: 'download_file', ids: [entity.project_id, entity.id] }
    when UploadBundle
      { entity_type: 'upload_bundle', ids: [entity.project_id, entity.id] }
    when UploadFile
      { entity_type: 'upload_file', ids: [entity.project_id, entity.upload_bundle_id, entity.id] }
    else
      raise ArgumentError, "Unknown entity type: #{entity.class}"
    end
  end
  private_class_method :parse_entity
end
