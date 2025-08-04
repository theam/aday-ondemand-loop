# frozen_string_literal: true

module Zenodo
  class DisplayRepoControllerResolver
    def initialize(object = nil)
      @url_helper = Rails.application.routes.url_helpers
    end

    def get_controller_url(object_url)
      zurl = Zenodo::ZenodoUrl.parse(object_url)
      scheme_param = zurl.scheme == 'https' ? nil : zurl.scheme
      port_param = zurl.port

      if zurl.record?
        redirect_url = @url_helper.explore_path(
          connector_type: 'zenodo',
          server_domain: zurl.domain,
          object_type: 'records',
          object_id: zurl.record_id,
          server_scheme: scheme_param,
          server_port: port_param
        )
      else
        message = { alert: I18n.t('connectors.zenodo.display_repo_controller.message_url_not_supported', url: object_url) }
        redirect_url = @url_helper.explore_path(
          connector_type: 'zenodo',
          server_domain: zurl.domain,
          object_type: 'actions',
          object_id: 'landing',
          server_scheme: scheme_param,
          server_port: port_param
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
