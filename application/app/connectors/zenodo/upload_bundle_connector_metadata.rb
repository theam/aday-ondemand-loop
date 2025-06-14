module Zenodo
  class UploadBundleConnectorMetadata
    def initialize(upload_bundle)
      @metadata = upload_bundle.metadata.to_h.deep_symbolize_keys
      @metadata.each_key do |key|
        define_singleton_method("#{key}=") { |value| @metadata[key] = value }
        define_singleton_method(key) { @metadata[key] }
      end
    end

    def method_missing(method_name, *arguments, &block)
      nil
    end

    def api_key
      OpenStruct.new({ value: @metadata[:api_key] }) if @metadata[:api_key]
    end

    def api_key?
      api_key.present?
    end

    def repo_name
      'Zenodo'
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
