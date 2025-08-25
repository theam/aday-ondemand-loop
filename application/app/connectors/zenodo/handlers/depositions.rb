module Zenodo::Handlers
  class Depositions
    include LoggingCommon

    def initialize(object_id = nil)
      @deposition_id = object_id
    end

    def params_schema
      [
        :repo_url,
        :project_id,
        { file_ids: [] }
      ]
    end

    def show(request_params)
      repo_url = request_params[:repo_url]
      repo_info = RepoRegistry.repo_db.get(repo_url.server_url)
      api_key = repo_info&.metadata&.auth_key

      unless api_key
        return ConnectorResult.new(
          message: { alert: I18n.t('zenodo.depositions.message_api_key_required') },
          success: false
        )
      end

      service = Zenodo::DepositionService.new(repo_url.server_url, api_key: api_key)
      deposition = service.find_deposition(@deposition_id)
      if deposition.nil?
        return ConnectorResult.new(
          message: { alert: I18n.t('zenodo.depositions.message_deposition_not_found', deposition_id: @deposition_id) },
          success: false
        )
      end

      external_url = Zenodo::Concerns::ZenodoUrlBuilder.build_deposition_url(repo_url.server_url, @deposition_id)

      RepoRegistry.repo_history.add_repo(
        external_url,
        ConnectorType::ZENODO,
        title: deposition.title,
        note: deposition.version
      )

      ConnectorResult.new(
        template: '/connectors/zenodo/depositions/show',
        locals: {
          dataset: deposition,
          dataset_id: @deposition_id,
          repo_url: repo_url,
          dataset_title: deposition.title,
          external_zenodo_url: external_url
        },
        resource: deposition,
        success: true
      )
    rescue Zenodo::ApiService::ApiKeyRequiredException
      ConnectorResult.new(
        message: { alert: I18n.t('zenodo.depositions.message_api_key_required') },
        success: false
      )
    end

    def create(request_params)
      repo_url = request_params[:repo_url]
      file_ids = request_params[:file_ids] || []
      project_id = request_params[:project_id]

      repo_info = RepoRegistry.repo_db.get(repo_url.server_url)
      api_key = repo_info&.metadata&.auth_key

      service = Zenodo::DepositionService.new(repo_url.server_url, api_key: api_key)
      deposition = service.find_deposition(@deposition_id)
      return ConnectorResult.new(message: { alert: I18n.t('zenodo.depositions.message_deposition_not_found', deposition_id: @deposition_id) }, success: false) unless deposition

      project = Project.find(project_id)
      project_service = Zenodo::ProjectService.new(repo_url.server_url)
      if project.nil?
        project = project_service.initialize_project
        unless project.save
          errors = project.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('zenodo.depositions.message_project_error', errors: errors) }, success: false)
        end
      end

      download_files = project_service.create_files_from_deposition(project, deposition, file_ids)
      download_files.each do |file|
        unless file.valid?
          errors = file.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('zenodo.depositions.message_validation_file_error', filename: file.filename, errors: errors) }, success: false)
        end
      end
      save_results = download_files.map(&:save)
      if save_results.include?(false)
        return ConnectorResult.new(message: { alert: I18n.t('zenodo.depositions.message_save_file_error', project_name: project.name) }, success: false)
      end
      ConnectorResult.new(message: { notice: I18n.t('zenodo.depositions.message_success', files: save_results.size, project_name: project.name) }, success: true)
    end
  end
end

