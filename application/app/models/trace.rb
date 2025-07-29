# frozen_string_literal: true

class Trace < ApplicationDiskRecord
  include ActiveModel::Model
  include DateTimeCommon

  ATTRIBUTES = %w[id entity_type entity_ids creation_date message].freeze

  attr_accessor(*ATTRIBUTES)

  validates_presence_of :id, :entity_type, :creation_date, :message

  def self.add(entity_type:, entity_ids:, message:)
    trace = new(
      id: generate_id,
      entity_type: entity_type.to_s,
      entity_ids: Array(entity_ids),
      creation_date: DateTimeCommon.now,
      message: message
    )
    trace.save
    trace
  end

  def self.record(entity, message)
    entity_type, ids = parse_entity(entity)
    add(entity_type: entity_type, entity_ids: ids, message: message)
  end

  def save
    return false unless valid?

    store_to_file(self.class.filename(entity_type, entity_ids, id))
  end

  def self.all(entity_type = nil, entity_ids = [])
    directory = directory(entity_type, entity_ids)
    return [] unless Dir.exist?(directory)

    Dir.glob(File.join(directory, '*.yml'))
       .sort_by { |f| -File.ctime(f).to_f }
       .map { |f| load_from_file(f) }
       .compact
  end

  def self.find(entity_type, entity_ids, trace_id)
    file = filename(entity_type, entity_ids, trace_id)
    return nil unless File.exist?(file)

    load_from_file(file)
  end

  def self.directory(entity_type, ids)
    File.join(metadata_root_directory, 'traces', entity_type.to_s, *Array(ids))
  end

  def self.filename(entity_type, ids, trace_id)
    File.join(directory(entity_type, ids), "#{trace_id}.yml")
  end

  def self.parse_entity(entity)
    case entity
    when Project
      ['project', [entity.id]]
    when DownloadFile
      ['download_file', [entity.project_id, entity.id]]
    when UploadBundle
      ['upload_bundle', [entity.project_id, entity.id]]
    when UploadFile
      ['upload_file', [entity.project_id, entity.upload_bundle_id, entity.id]]
    else
      raise ArgumentError, "Unknown entity type: #{entity.class}"
    end
  end
  private_class_method :parse_entity
end
