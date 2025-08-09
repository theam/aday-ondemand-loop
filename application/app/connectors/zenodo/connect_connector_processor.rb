module Zenodo
  class ConnectConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def action(action_name)
      ConnectorActionDispatcher.action(ConnectorType::ZENODO, action_name)
    end
  end
end
