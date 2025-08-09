module Dataverse
  class ConnectConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      [ :connector_type, :object_type, :page, :query ]
    end

    def show(request_params)
      action = ConnectorActionDispatcher.action(ConnectorType::DATAVERSE, request_params[:object_type])
      action.show(request_params)
    end
  end
end
