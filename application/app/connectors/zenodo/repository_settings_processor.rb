module Zenodo
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
        message: { notice: I18n.t('connectors.zenodo.actions.repository_settings_update.message_success', url: repo_url, type: repo.type) },
        success: true
      )
    end
  end
end
