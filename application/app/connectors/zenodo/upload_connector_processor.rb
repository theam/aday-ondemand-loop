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
      raise 'Missing record_id in connector metadata' unless connector_metadata.record_id

      # Step 1: Retrieve the deposition to get the bucket URL
      deposition_url = "/api/deposit/depositions/#{connector_metadata.record_id}"
      headers = { 'Authorization' => "Bearer #{connector_metadata.api_key&.value}" }

      deposition_response = Common::HttpClient.new(base_url: connector_metadata.zenodo_url)
                                              .get(deposition_url, headers: headers)

      log_info('response', {response: deposition_response.inspect})

      unless deposition_response.success?
        return response(FileStatus::ERROR, "Failed to retrieve deposition: #{deposition_response.status}")
      end

      deposition_data = deposition_response.json
      bucket_url = deposition_data.dig('links', 'bucket')
      return response(FileStatus::ERROR, 'Missing bucket URL in deposition') unless bucket_url

      # Step 2: Prepare file upload
      source_location = file.file_location
      file_name = File.basename(file.filename)
      upload_url = "#{bucket_url}/#{file_name}"

      connector_metadata.upload_url = upload_url
      file.upload_bundle.update({ metadata: connector_metadata.to_h })

      # Step 3: Upload the file using raw S3-compatible POST
      upload_processor = Zenodo::ZenodoBucketHttpUploader.new(upload_url, source_location, headers)
      upload_processor.upload do |context|
        @status_context = context
        cancelled
      end

      return response(FileStatus::CANCELLED, 'file upload cancelled') if cancelled

      # TODO: Zenodo does not verify MD5 on upload — this must be done client-side or skipped.
      connector_metadata.key_verified!
      response(FileStatus::SUCCESS, 'file upload completed')
    end

    def process(request)
      if request.command == 'upload.cancel'
        if file.id == request.body.file_id
          # CANCELLATION IS FOR THIS FILE
          @cancelled = true
          return {message: 'cancellation requested'}
        end
      end

      if request.command == 'upload.status'
        if file.id == request.body.file_id
          return {message: 'upload in progress', status: @status_context}
        end
      end

      return nil
    end

    private

    def response(status, message)
      OpenStruct.new({ status: status, message: message })
    end
  end
end
