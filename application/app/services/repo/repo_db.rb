# frozen_string_literal: true

module Repo
  class RepoDb
    include LoggingCommon

    class Entry < Struct.new(:type, :creation_date, :last_updated, :metadata, keyword_init: true)
      def type
        ConnectorType.get(self[:type])
      end

      def metadata
        OpenStruct.new(self[:metadata] || {})
      end

      def type=(value)
        raise ArgumentError, "Invalid type: #{value}" unless value.is_a?(ConnectorType)
        self[:type] = value.to_s
      end
    end

    attr_reader :db_path

    def initialize(db_path:)
      @db_path = db_path
      @data = load_data
    end

    def get(repo_url)
      @data[repo_url]
    end

    def set(repo_url, type:, metadata: nil)
      raise ArgumentError, "Invalid type: #{type}" unless type.is_a?(ConnectorType)

      existing = @data[repo_url]
      metadata = existing&.metadata.to_h if metadata.nil?
      creation_date = existing&.creation_date || Time.now.to_s
      @data[repo_url] = Entry.new(
        type: type.to_s,
        creation_date: creation_date,
        last_updated: Time.now.to_s,
        metadata: metadata
      )
      persist!
      log_info('Entry added', {repo_url: repo_url, type: type})
    end

    def update(repo_url, metadata:)
      raise ArgumentError, "Unknown repo url: #{repo_url}" unless @data.key?(repo_url)

      entry = @data[repo_url]
      entry.last_updated = Time.now.to_s
      entry[:metadata] ||= {}
      entry[:metadata] = entry[:metadata].merge(metadata)
      persist!
      log_info('Entry updated', { repo_url: repo_url, type: entry.type })
    end

    def delete(repo_url)
      return unless @data.key?(repo_url)

      entry = @data.delete(repo_url)
      persist!
      log_info('Entry deleted', { repo_url: repo_url, type: entry&.type })
    end

    def size
      @data.size
    end

    def all
      @data
    end

    private

    def load_data
      return {} unless File.exist?(db_path)

      raw = YAML.load_file(db_path) || {}
      raw.transform_values do |v|
        v = v.symbolize_keys
        Entry.new(
          type: v[:type],
          creation_date: v[:creation_date],
          last_updated: v[:last_updated],
          metadata: v[:metadata] || {}
        )
      end
    end

    def persist!
      FileUtils.mkdir_p(File.dirname(db_path))
      File.write(db_path, YAML.dump(@data.transform_values(&:to_h)))
    end
  end
end
