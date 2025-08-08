module Dataverse
  class ExploreConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      %i[
        connector_type object_type object_id
        page query
      ]
    end

    def show(request_params)
      explorer = ConnectorActionDispatcher.explorer(request_params[:connector_type], request_params[:object_type], request_params[:object_id])
      explorer.show(request_params)
    end

    def create(_request_params)
      ConnectorResult.new(
        message: { notice: I18n.t('explore.show.message_success') },
        success: true
      )
    end

    def landing(request_params)
      explorer = Dataverse::Explorers::Landing.new
      explorer.show(request_params)
    end
  end
end
