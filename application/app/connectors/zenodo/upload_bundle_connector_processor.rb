# frozen_string_literal: true

module Zenodo
  class UploadBundleConnectorProcessor
    def initialize(object = nil); end

    def params_schema
      %i[remote_repo_url api_key dataset_id]
    end

    def create(project, request_params)
      ConnectorResult.new(success: true)
    end

    def edit(upload_bundle, request_params)
      ConnectorResult.new(partial: '/connectors/zenodo/connector_edit_form', locals: { upload_bundle: upload_bundle })
    end

    def update(upload_bundle, request_params)
      metadata = upload_bundle.metadata
      metadata[:api_key] = request_params[:api_key]
      metadata[:dataset_id] = request_params[:dataset_id]
      upload_bundle.update(metadata: metadata)
      ConnectorResult.new(success: true, message: { notice: I18n.t('connectors.zenodo.actions.connector_edit.success', name: upload_bundle.name) })
    end
  end
end
