module Zenodo::Actions
  class Records
    include LoggingCommon

    def initialize(record_id)
      @record_id = record_id
    end

    def show(request_params)
      repo_url = request_params[:repo_url]

      service = Zenodo::RecordService.new(repo_url.server_url)
      record = service.find_record(@record_id)
      if record.nil?
        return ConnectorResult.new(
          message: { alert: I18n.t('zenodo.records.message_record_not_found', record_id: @record_id) },
          success: false
        )
      end

      ConnectorResult.new(
        template: '/connectors/zenodo/record',
        locals: {
          record: record,
          record_id: @record_id,
          repo_url: repo_url
        },
        success: true
      )
    rescue => e
      log_error('Find record error', { record_id: @record_id }, e)
      ConnectorResult.new(
        message: { alert: I18n.t('zenodo.records.message_record_service_error', record_id: @record_id) },
        success: false
      )
    end

    def create(request_params)
      repo_url = request_params[:repo_url]
      file_ids = request_params[:file_ids] || []
      project_id = request_params[:project_id]

      record_service = Zenodo::RecordService.new(repo_url.server_url)
      record = record_service.find_record(@record_id)
      return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_record_not_found', record_id: @record_id) }, success: false) unless record

      project = Project.find(project_id)
      project_service = Zenodo::ProjectService.new(repo_url.server_url)
      if project.nil?
        project = project_service.initialize_project
        unless project.save
          errors = project.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.download.message_project_error', errors: errors) }, success: false)
        end
      end

      download_files = project_service.initialize_download_files(project, record, file_ids)
      download_files.each do |file|
        unless file.valid?
          errors = file.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.download.message_validation_file_error', filename: file.filename, errors: errors) }, success: false)
        end
      end
      save_results = download_files.map(&:save)
      if save_results.include?(false)
        return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.download.message_save_file_error') }, success: false)
      end
      ConnectorResult.new(message: { notice: I18n.t('zenodo.records.download.message_success', project_name: project.name) }, success: true)
    rescue => e
      log_error('Download files error', { record_id: @record_id }, e)
      ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_record_service_error', record_id: @record_id) }, success: false)
    end
  end
end
