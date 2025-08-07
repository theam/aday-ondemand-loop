# frozen_string_literal: true

module Dataverse
  # Dataverse controller resolver to parse URLs and redirect to the relevant Dataverse controller to display the data.
  class DisplayRepoControllerResolver
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
      @url_helper = Rails.application.routes.url_helpers
    end

    def get_controller_url(object_url)
      dataverse_url = Dataverse::DataverseUrl.parse(object_url)
      message = nil

      if dataverse_url.nil?
        redirect_url = @url_helper.explore_landing_path(connector_type: ConnectorType::DATAVERSE.to_s)
      elsif dataverse_url.dataverse? || (dataverse_url.file? && dataverse_url.dataset_id.nil?)
        redirect_url = @url_helper.view_dataverse_path(dataverse_url.domain, ':root', dv_scheme: dataverse_url.scheme_override, dv_port: dataverse_url.port)
      elsif dataverse_url.collection?
        redirect_url = @url_helper.view_dataverse_path(dataverse_url.domain, dataverse_url.collection_id, dv_scheme: dataverse_url.scheme_override, dv_port: dataverse_url.port)
      elsif dataverse_url.dataset? || dataverse_url.file?
        redirect_url = @url_helper.view_dataverse_dataset_path(
          dv_hostname: dataverse_url.domain,
          persistent_id: dataverse_url.dataset_id,
          dv_scheme: dataverse_url.scheme_override,
          dv_port: dataverse_url.port,
          version: dataverse_url.version
        )
      else
        redirect_url = @url_helper.explore_landing_path(connector_type: ConnectorType::DATAVERSE.to_s)
        message = { alert: I18n.t('connectors.dataverse.display_repo_controller.message_url_not_supported', url: object_url) }
      end

      ConnectorResult.new(
        redirect_url: redirect_url,
        message: message,
        success: true,
        )
    end

  end

end
