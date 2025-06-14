module Zenodo
  class UploadBundleConnectorProcessor
    include LoggingCommon
    def initialize(object = nil)
    end

    def params_schema
      %i[remote_repo_url form api_key dataset_id]
    end

    def create(project, request_params)
      url_data = Zenodo::ZenodoUrl.parse(request_params[:object_url])
      dataset_id = url_data&.record_id
      upload_bundle = UploadBundle.new.tap do |b|
        b.id = File.join(url_data.domain, UploadBundle.generate_code)
        b.name = b.id
        b.project_id = project.id
        b.remote_repo_url = request_params[:object_url]
        b.type = ConnectorType::ZENODO
        b.creation_date = Time.now
        b.metadata = {
          dataset_id: dataset_id,
          api_key: request_params[:api_key]
        }
      end
      upload_bundle.save
      ConnectorResult.new(resource: upload_bundle, success: true, message: { notice: 'Upload bundle created' })
    end

    def edit(upload_bundle, request_params)
      ConnectorResult.new(partial: '/connectors/zenodo/connector_edit_form', locals: { upload_bundle: upload_bundle })
    end

    def update(upload_bundle, request_params)
      metadata = upload_bundle.metadata
      metadata[:api_key] = request_params[:api_key]
      upload_bundle.update({ metadata: metadata })
      ConnectorResult.new(message: { notice: 'API Key updated' }, success: true)
    end
  end
end
