module Zenodo
  class UploadConnectorProcessor
    include LoggingCommon

    attr_reader :file, :connector_metadata, :cancelled, :status_context
    def initialize(file)
      @file = file
      @connector_metadata = file.upload_bundle.connector_metadata
      @cancelled = false
      @status_context = nil
      Command::CommandRegistry.instance.register('upload.cancel', self)
      Command::CommandRegistry.instance.register('upload.status', self)
    end

    def upload
      # TODO: implement real upload using Zenodo API
      connector_metadata.key_verified!
      response(FileStatus::SUCCESS, 'file upload completed')
    end

    def process(request)
      if request.command == 'upload.cancel' && file.id == request.body.file_id
        @cancelled = true
        return {message: 'cancellation requested'}
      end
      if request.command == 'upload.status' && file.id == request.body.file_id
        return {message: 'upload in progress', status: @status_context}
      end
      nil
    end

    private

    def response(file_status, message)
      OpenStruct.new({status: file_status, message: message})
    end
  end
end
