module Zenodo::Handlers
  class Records
    include LoggingCommon

    def initialize(object_id = nil)
      @record_id = object_id
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
      log_info('Record show', { record_id: @record_id, repo_url: repo_url })

      service = Zenodo::RecordService.new(repo_url.server_url)
      record = service.find_record(@record_id)
      if record.nil?
        log_info('Record not found', { record_id: @record_id })
        return ConnectorResult.new(
          message: { alert: I18n.t('zenodo.records.message_record_not_found', record_id: @record_id) },
          success: false
        )
      end

      external_url = Zenodo::Concerns::ZenodoUrlBuilder.build_record_url(repo_url.server_url, @record_id)

      ConnectorResult.new(
        template: '/connectors/zenodo/records/show',
        locals: {
          dataset: record,
          dataset_id: @record_id,
          repo_url: repo_url,
          dataset_title: record.title,
          external_zenodo_url: external_url
        },
        success: true,
        resource: record,
        resource_url: external_url
      )
    end

    def create(request_params)
      repo_url = request_params[:repo_url]
      file_ids = request_params[:file_ids] || []
      project_id = request_params[:project_id]
      log_info('Record create', { record_id: @record_id, project_id: project_id, file_ids: file_ids })

      record_service = Zenodo::RecordService.new(repo_url.server_url)
      record = record_service.find_record(@record_id)
      return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_record_not_found', record_id: @record_id) }, success: false) unless record

      project = Project.find(project_id)
      project_service = Zenodo::ProjectService.new(repo_url.server_url)
      if project.nil?
        project = project_service.initialize_project
        unless project.save
          errors = project.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_project_error', errors: errors) }, success: false)
        end
      end

      download_files = project_service.create_files_from_record(project, record, file_ids)
      download_files.each do |file|
        unless file.valid?
          errors = file.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_validation_file_error', filename: file.filename, errors: errors) }, success: false)
        end
      end
      save_results = download_files.map(&:save)
      if save_results.include?(false)
        return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_save_file_error', project_name: project.name) }, success: false)
      end
      log_info('Download files created', { project_id: project.id, files: download_files.size })
      ConnectorResult.new(message: { notice: I18n.t('zenodo.records.message_success', files: save_results.size, project_name: project.name) }, success: true)
    end
  end
end

