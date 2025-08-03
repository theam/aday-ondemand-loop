module Zenodo
  class ExploreConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      %i[connector_type server_domain object_type object_id server_scheme server_port query page per_page]
    end

    def show(request_params)
      if request_params[:object_type] == 'actions'
        action = ConnectorActionDispatcher.load(
          request_params[:connector_type],
          request_params[:object_type],
          request_params[:object_id]
        )
        action.show(request_params)
      else
        ConnectorResult.new(
          template: '/connectors/zenodo/explore_placeholder',
          locals: { data: request_params },
          message: { notice: I18n.t('explore.show.message_success') },
          success: true
        )
      end
    rescue ConnectorActionDispatcher::ConnectorNotSupported => e
      log_error('Zenodo explore action not found', { action: request_params[:object_id] }, e)
      ConnectorResult.new(
        template: '/connectors/zenodo/explore_placeholder',
        locals: { data: request_params },
        message: { alert: I18n.t('explore.show.message_action_not_found', action: request_params[:object_id]) },
        success: false
      )
    end
  end
end
