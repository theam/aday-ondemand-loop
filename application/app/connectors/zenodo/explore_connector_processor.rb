module Zenodo
  class ExploreConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      [
        :connector_type, :server_domain, :object_type, :object_id,
        :server_scheme, :server_port, :query, :page, :per_page,
        :project_id, { file_ids: [] }
      ]
    end

    def show(request_params)
      action = ConnectorActionDispatcher.load(
        request_params[:connector_type],
        request_params[:object_type],
        request_params[:object_id]
      )
      action.show(request_params)
    rescue ConnectorActionDispatcher::ConnectorNotSupported => e
      log_error('Zenodo explore action not found', { action: request_params[:object_id] }, e)
      ConnectorResult.new(
        template: '/connectors/zenodo/explore_placeholder',
        locals: { data: request_params },
        message: { alert: I18n.t('explore.show.message_action_not_found', action: request_params[:object_id]) },
        success: false
      )
    end

    def create(request_params)
      action = ConnectorActionDispatcher.load(
        request_params[:connector_type],
        request_params[:object_type],
        request_params[:object_id]
      )
      action.create(request_params)
    rescue ConnectorActionDispatcher::ConnectorNotSupported => e
      log_error('Zenodo explore action not found', { action: request_params[:object_id] }, e)
      ConnectorResult.new(
        message: { alert: I18n.t('explore.show.message_action_not_found', action: request_params[:object_id]) },
        success: false
      )
    end
  end
end
