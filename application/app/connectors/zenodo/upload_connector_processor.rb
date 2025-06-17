# frozen_string_literal: true

module Zenodo
  class UploadConnectorProcessor
    include LoggingCommon

    attr_reader :file, :connector_metadata, :cancelled
    def initialize(file)
      @file = file
      @connector_metadata = file.upload_bundle.connector_metadata
      @cancelled = false
      Command::CommandRegistry.instance.register('upload.cancel', self)
      Command::CommandRegistry.instance.register('upload.status', self)
    end

    def upload
      # Placeholder: Zenodo upload API call would go here
      connector_metadata.temp_location = file.file_location
      file.upload_bundle.update(metadata: connector_metadata.to_h)
      response(FileStatus::SUCCESS, 'file upload completed')
    end

    def process(request)
      if request.command == 'upload.cancel' && file.id == request.body.file_id
        @cancelled = true
        return { message: 'cancellation requested' }
      end
      nil
    end

    private

    def response(status, message)
      OpenStruct.new({ status: status, message: message })
    end
  end
end
