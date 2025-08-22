# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module Repo
  class RepoHistory
    include DateTimeCommon
    include LoggingCommon

    class Entry
      attr_accessor :repo_url, :metadata, :count, :last_added

      def initialize(repo_url:, type:, metadata:, count:, last_added:)
        @repo_url = repo_url
        @type = type
        @metadata = metadata || {}
        @count = count
        @last_added = last_added
      end

      def type
        ConnectorType.get(@type) if @type
      end

      def type=(val)
        @type = val
      end

      def metadata=(val)
        @metadata = val || {}
      end

      def to_h
        {
          repo_url: @repo_url,
          type: @type,
          metadata: @metadata,
          count: @count,
          last_added: @last_added
        }
      end
      alias_method :to_hash, :to_h
    end

    DEFAULT_MAX_ENTRIES = 100

    attr_reader :db_path, :max_entries

    def initialize(db_path:, max_entries: DEFAULT_MAX_ENTRIES)
      @db_path = db_path
      @max_entries = max_entries
      @data = load_data
    end

    def add_repo(url, type, metadata = {})
      raise ArgumentError, "Invalid type: #{type}" unless type.is_a?(ConnectorType)

      now_time = now
      added = nil
      new_data = []

      @data.each do |e|
        if e.repo_url == url
          added ||= e
          added.count += e.count
          next
        end

        new_data << e
        break if new_data.size >= max_entries - 1
      end

      added ||= Entry.new(repo_url: url, type: type.to_s, metadata: {}, count: 0, last_added: now_time)
      added.type = type.to_s
      added.metadata = metadata || {}
      added.count += 1
      added.last_added = now_time

      @data = [added] + new_data
      persist!
      log_info('Repo added', { repo_url: url, type: type })
      added
    end

    def get(url)
      @data.find { |e| e.repo_url == url }
    end

    def all
      @data
    end

    def size
      @data.size
    end

    private

    def load_data
      return [] unless File.exist?(db_path)

      raw = YAML.load_file(db_path) || []
      entries = raw.map do |v|
        v = v.symbolize_keys
        Entry.new(
          repo_url: v[:repo_url],
          type: v[:type],
          metadata: v[:metadata] || {},
          count: v[:count] || 0,
          last_added: v[:last_added]
        )
      end
      entries.sort_by(&:last_added).reverse
    end

    def persist!
      FileUtils.mkdir_p(File.dirname(db_path))
      File.write(db_path, YAML.dump(@data.map(&:to_h)))
    end
  end
end
