module Repo
  class RepoHistory
    include LoggingCommon
    include DateTimeCommon

    Entry = Struct.new(:object_url, :type, :creation_date, :metadata, keyword_init: true) do
      def type
        ConnectorType.get(self[:type])
      end

      def metadata
        OpenStruct.new(self[:metadata] || {})
      end

      def to_h
        {
          object_url: self[:object_url],
          type: self[:type],
          creation_date: self[:creation_date],
          metadata: self[:metadata]
        }
      end
      alias_method :to_hash, :to_h
    end

    attr_reader :history_path

    def initialize(history_path:)
      @history_path = history_path
      @data = load_data
    end

    def add(object_url:, type:, metadata: {})
      raise ArgumentError, "Invalid type: #{type}" unless type.is_a?(ConnectorType)

      entry = Entry.new(
        object_url: object_url.strip,
        type: type.to_s,
        creation_date: now,
        metadata: metadata
      )
      @data << entry
      persist!
      log_info('Entry added', { object_url: object_url, type: type })
      entry
    end

    def all
      @data
    end

    def size
      @data.size
    end

    def find_by_object_url(url)
      @data.find { |e| e.object_url == url.strip }
    end

    private

    def load_data
      return [] unless File.exist?(history_path)
      raw = YAML.load_file(history_path) || []
      raw.map do |v|
        v = v.symbolize_keys
        Entry.new(
          object_url: v[:object_url],
          type: v[:type],
          creation_date: v[:creation_date],
          metadata: v[:metadata] || {}
        )
      end
    end

    def persist!
      FileUtils.mkdir_p(File.dirname(history_path))
      File.write(history_path, YAML.dump(@data.map(&:to_h)))
    end
  end
end
