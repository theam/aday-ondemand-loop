module Dataverse
  class DatasetVersionsResponse
    attr_reader :status, :versions

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @versions = (parsed[:data] || []).map do |v|
        Data.new(v)
      end
    end

    class Data
      attr_reader :id, :dataset_id, :dataset_persistent_id, :dataset_type,
                  :storage_identifier, :internal_version_number, :version_state,
                  :last_update_time, :create_time, :publication_date

      def initialize(data)
        data ||= {}
        @id = data[:id]
        @dataset_id = data[:datasetId]
        @dataset_persistent_id = data[:datasetPersistentId]
        @dataset_type = data[:datasetType]
        @storage_identifier = data[:storageIdentifier]
        @internal_version_number = data[:internalVersionNumber]
        @version_state = data[:versionState]
        @last_update_time = data[:lastUpdateTime]
        @create_time = data[:createTime]
        @publication_date = data[:publicationDate]
      end
    end
  end
end
