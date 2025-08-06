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
      load_explorer(request_params).show(request_params)
    end

    def create(request_params)
      load_explorer(request_params).create(request_params)
    end

    private

    def load_explorer(request_params)
      explorer_type = request_params[:object_type]
      object_id = request_params[:object_id]
      if object_id.present?
        ConnectorActionDispatcher.explorer(request_params[:connector_type], explorer_type, object_id)
      else
        ConnectorActionDispatcher.explorer(request_params[:connector_type], :explorers, explorer_type)
      end
    end

    def landing(_request_params)
      ConnectorResult.new(
        message: { alert: I18n.t('connectors.zenodo.actions.landing.message_action_not_supported') },
        success: false
      )
    end
  end
end
