module Zenodo
  class DisplayRepoControllerResolver
    include LoggingCommon

    def initialize(object = nil)
      @url_helper = Rails.application.routes.url_helpers
    end

    def get_controller_url(object_url)
      zenodo_url = Zenodo::ZenodoUrl.parse(object_url)
      if zenodo_url&.record?
        redirect_url = @url_helper.view_zenodo_record_path(z_hostname: zenodo_url.domain, id: zenodo_url.record_id, z_scheme: zenodo_url.scheme_override, z_port: zenodo_url.port)
      else
        redirect_url = @url_helper.view_zenodo_landing_path
      end
      ConnectorResult.new(redirect_url: redirect_url, success: true)
    end
  end
end
