module Dataverse
  class ExploreConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      [
        :connector_type, :object_type, :object_id,
        :page, :query, :version,
        :project_id, { file_ids: [] }
      ]
    end

    def show(request_params)
      explorer = load_explorer(request_params)
      explorer.show(request_params)
    end

    def create(request_params)
      explorer = load_explorer(request_params)
      explorer.create(request_params)
    end

    def landing(request_params)
      explorer = Dataverse::Explorers::Landing.new
      explorer.show(request_params)
    end

    private

    def load_explorer(request_params)
      ConnectorActionDispatcher.explorer(request_params[:connector_type], request_params[:object_type], request_params[:object_id])
    end
  end
end
