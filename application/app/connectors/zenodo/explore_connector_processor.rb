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
    rescue ConnectorActionDispatcher::ConnectorNotSupported => e
      log_error('Zenodo explore action not found', { action_type: action_type, object_id: object_id }, e)
      ConnectorResult.new(
        template: '/connectors/zenodo/explore_placeholder',
        locals: { data: request_params },
        message: { alert: I18n.t('explore.show.message_action_not_found', action: action_type) },
        success: false
      )
    end

    def create(request_params)
      action_type = request_params[:object_type]
      object_id = request_params[:object_id]
      action = ConnectorActionDispatcher.load(request_params[:connector_type], action_type, object_id)
      action.create(request_params)
    rescue ConnectorActionDispatcher::ConnectorNotSupported => e
      log_error('Zenodo explore action not found', { action_type: action_type, object_id: object_id }, e)
      ConnectorResult.new(
        message: { alert: I18n.t('explore.show.message_action_not_found', action: action_type) },
        success: false
      )
    end
  end
end
