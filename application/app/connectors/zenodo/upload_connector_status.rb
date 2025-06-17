# frozen_string_literal: true

module Zenodo
  class UploadConnectorStatus
    attr_reader :file
    def initialize(file)
      @file = file
    end
    def upload_progress
      return 100 if FileStatus.completed_statuses.include?(file.status)
      0
    end
  end
end
