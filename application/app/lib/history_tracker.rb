# frozen_string_literal: true

require 'yaml'
require 'fileutils'

# HistoryTracker keeps track of recently used values per type.
# Data is persisted in YAML format and loaded lazily.
class HistoryTracker
  include LoggingCommon

  # save_interval is in seconds and defaults to 15 minutes
  def initialize(file_path: nil, max_per_type: 10, save_interval: 15 * 60)
    @file_path = Pathname.new(file_path || Configuration.history_tracker_file)
    @max_per_type = max_per_type
    @save_interval = save_interval
    @data = {}
    @loaded = false
    @last_saved = Time.now
  end

  # Add a value for the given item type (symbol or string)
  def add(item_type, value)
    load
    key = item_type.to_s
    list = @data[key] || []
    new_list = [value]
    list.each do |v|
      next if v == value
      new_list << v
      break if new_list.length >= @max_per_type
    end
    @data[key] = new_list
    save
  end

  # Get history values for the given type
  def get(item_type)
    load
    @data[item_type.to_s] || []
  end

  # Load history from disk
  def load(force: false)
    return if @loaded && !force

    if @file_path.exist?
      begin
        raw = YAML.safe_load(@file_path.read) || {}
        @data = raw.transform_values { |v| Array(v) }
      rescue StandardError => e
        log_error('Cannot load history file', { path: @file_path }, e)
        @data = {}
      end
    else
      @data = {}
    end

    @loaded = true
  end

  # Persist history to disk
  def save(force: false)
    load unless @loaded
    return unless force || Time.now - @last_saved >= @save_interval

    FileUtils.mkdir_p(@file_path.dirname)
    File.write(@file_path, YAML.dump(@data))
    @last_saved = Time.now
  end

  # Force persistence immediately
  def flush
    save(force: true)
  end
end
