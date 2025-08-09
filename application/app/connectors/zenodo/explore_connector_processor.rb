module Zenodo
  class ExploreConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      [
        :connector_type, :object_type, :object_id,
        :query, :page,
        :project_id, { file_ids: [] }
      ]
    end

    def show(request_params)
      handler = load_handler(request_params)
      handler.show(request_params)
    end

    def create(request_params)
      handler = load_handler(request_params)
      handler.create(request_params)
    end

    private

    def load_handler(request_params)
      ConnectorHandlerDispatcher.handler(
        request_params[:connector_type],
        request_params[:object_type],
        request_params[:object_id]
      )
    end
  end
end
