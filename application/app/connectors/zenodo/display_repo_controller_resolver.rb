# frozen_string_literal: true

module Zenodo
  class DisplayRepoControllerResolver
    def initialize(object = nil)
      @url_helper = Rails.application.routes.url_helpers
    end

    def get_controller_url(object_url)
      zurl = Zenodo::ZenodoUrl.parse(object_url)

      if zurl.record?
        redirect_url = @url_helper.explore_path(
          connector_type: ConnectorType::ZENODO.to_s,
          server_domain: zurl.domain,
          object_type: 'records',
          object_id: zurl.record_id,
          server_scheme: zurl.scheme_override,
          server_port: zurl.port_override
        )
      else
        message = { alert: I18n.t('connectors.zenodo.display_repo_controller.message_url_not_supported', url: object_url) }
        redirect_url = @url_helper.explore_path(
          connector_type: ConnectorType::ZENODO.to_s,
          server_domain: zurl.domain,
          object_type: 'actions',
          object_id: 'landing',
          server_scheme: zurl.scheme_override,
          server_port: zurl.port_override
        )
      end

      ConnectorResult.new(
        redirect_url: redirect_url,
        message: message,
        success: true
      )
    end
  end
end
