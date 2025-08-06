module Dataverse
  class ExploreConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      %i[connector_type server_domain object_type object_id server_scheme server_port]
    end

    def show(request_params)
      ConnectorResult.new(
        template: '/connectors/dataverse/explore_placeholder',
        locals: { data: request_params },
        success: true
      )
    end

    def create(_request_params)
      ConnectorResult.new(
        message: { notice: I18n.t('explore.show.message_success') },
        success: true
      )
    end

    def landing(request_params)
      ConnectorResult.new(
        template: '/connectors/dataverse/explore_placeholder',
        locals: { data: request_params },
        success: true
      )
    end
  end
end
