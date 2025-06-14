module Zenodo
  class UploadConnectorStatus
    attr_reader :file, :connector_metadata

    def initialize(file)
      @file = file
      @connector_metadata = file.upload_bundle.connector_metadata
    end

    def upload_progress
      return 0 if FileStatus.new_statuses.include?(file.status)
      return 100 if FileStatus.completed_statuses.include?(file.status)
      0
    end
  end
end
