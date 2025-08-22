# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module Repo
  class RepoHistory
    include DateTimeCommon
    include LoggingCommon

    Entry = Struct.new(:repo_url, :type, :metadata, :count, :last_added, keyword_init: true) do
      def initialize(**kwargs)
        super
        freeze
      end

      def with(**attrs)
        self.class.new(to_h.merge(attrs).merge(repo_url: repo_url))
      end

      def type
        ConnectorType.get(self[:type]) if self[:type]
      end

      def metadata
        self[:metadata] || {}
      end

      def to_h
        {
          type: self[:type],
          metadata: self[:metadata],
          count: self[:count],
          last_added: self[:last_added]
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
      entry = @data[url]
      if entry
        entry = entry.with(type: type.to_s, metadata: metadata || {}, count: entry.count.to_i + 1,
                           last_added: now_time)
      else
        entry = Entry.new(repo_url: url, type: type.to_s, metadata: metadata || {}, count: 1, last_added: now_time)
      end
      @data[url] = entry
      @data = @data.sort_by { |_, e| e.last_added }.reverse.to_h
      prune!
      persist!
      log_info('Repo added', { repo_url: url, type: type })
      entry
    end

    def get(url)
      @data[url]
    end

    def all
      @data
    end

    def size
      @data.size
    end

    private

    def load_data
      return {} unless File.exist?(db_path)

      raw = YAML.load_file(db_path) || {}
      data = raw.each_with_object({}) do |(url, v), memo|
        v = v.symbolize_keys
        memo[url] = Entry.new(
          repo_url: url,
          type: v[:type],
          metadata: v[:metadata] || {},
          count: v[:count] || 0,
          last_added: v[:last_added]
        )
      end
      data.sort_by { |_, e| e.last_added }.reverse.to_h
    end

    def persist!
      FileUtils.mkdir_p(File.dirname(db_path))
      File.write(db_path, YAML.dump(@data.transform_values(&:to_h)))
    end

    def prune!
      while @data.size > max_entries
        oldest_url, _ = @data.min_by { |_, e| e.last_added }
        @data.delete(oldest_url)
      end
    end
  end
end
