module Zenodo
  class DownloadConnectorMetadata
    def initialize(download_file)
      @metadata = download_file.metadata.to_h.deep_symbolize_keys
      @metadata.each_key do |key|
        define_singleton_method("#{key}=") { |value| @metadata[key] = value }
        define_singleton_method(key) { @metadata[key] }
      end
    end

    def method_missing(method_name, *arguments, &block)
      nil
    end

    def repo_name
      'Zenodo'
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
