module Zenodo
  module Actions
    class ConnectorEdit
      def edit(upload_bundle, request_params)
        ConnectorResult.new(
          partial: '/connectors/zenodo/connector_edit_form',
          locals: { upload_bundle: upload_bundle }
        )
      end

      def update(upload_bundle, request_params)
        metadata = upload_bundle.metadata
        metadata[:api_key] = request_params[:api_key]
        upload_bundle.update({ metadata: metadata })
        ConnectorResult.new(message: { notice: 'API Key updated' }, success: true)
      end
    end
  end
end
