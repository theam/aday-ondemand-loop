# frozen_string_literal: true

module Zenodo
  class UploadBundleConnectorMetadata
    include Zenodo::Concerns::ZenodoUrlBuilder
    def initialize(upload_bundle)
      @metadata = upload_bundle.metadata.to_h.deep_symbolize_keys
      @metadata.each_key do |key|
        define_singleton_method("#{key}=") { |value| @metadata[key] = value }
        define_singleton_method(key) { @metadata[key] }
      end
    end

    def method_missing(method_name, *args, &block)
      nil
    end

    def api_key
      return OpenStruct.new({ bundle?: true, server?: false, value: @metadata[:auth_key] }) if @metadata[:auth_key]

      repo_info = RepoRegistry.repo_db.get(server_domain)
      OpenStruct.new({ bundle?: false, server?: true, value: repo_info.metadata.auth_key }) if repo_info && repo_info.metadata.auth_key
    end

    def api_key?
      api_key.present?
    end

    def display_record?
      record_title.present?
    end

    def select_record?
      api_key? && record_id.nil?
    end

    def api_key_required?
      api_key.nil? && record_id.nil?
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
