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
      action_type = request_params[:object_type]
      object_id = request_params[:object_id]
      action = ConnectorActionDispatcher.load(request_params[:connector_type], action_type, object_id)
      action.show(request_params)
    end

    def create(request_params)
      action_type = request_params[:object_type]
      object_id = request_params[:object_id]
      action = ConnectorActionDispatcher.load(request_params[:connector_type], action_type, object_id)
      action.create(request_params)
    end
  end
end
