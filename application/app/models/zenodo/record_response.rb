module Zenodo
  class RecordResponse
    attr_reader :id, :metadata, :files

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @id = parsed[:id]
      @metadata = OpenStruct.new(parsed[:metadata] || {})
      @files = (parsed[:files] || []).map { |f| File.new(f) }
    end

    class File
      attr_reader :id, :filename, :filesize, :checksum, :links

      def initialize(attrs)
        attrs ||= {}
        @id = attrs[:id]
        @filename = attrs[:key]
        @filesize = attrs[:size]
        @checksum = attrs[:checksum]
        @links = attrs[:links] || {}
      end

      def download_url
        @links[:download] || @links[:self]
      end
    end
  end
end
