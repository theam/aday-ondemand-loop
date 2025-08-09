module Dataverse
  class ConnectConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def action(action_name)
      ConnectorActionDispatcher.action(ConnectorType::DATAVERSE, action_name)
    end
  end
end
