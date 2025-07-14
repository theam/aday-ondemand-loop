module Dataverse
  class RepositorySettingsProcessor
    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      [:repo_url, :auth_key]
    end

    def update(repo, request_params)
      repo_url = request_params[:repo_url]
      RepoRegistry.repo_db.update(repo_url, metadata: { auth_key: request_params[:auth_key] })
      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.actions.repository_settings_create.message_success', domain: repo_url) },
        success: true
      )
    end
  end
end
