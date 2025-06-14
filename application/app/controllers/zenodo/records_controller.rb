class Zenodo::RecordsController < ApplicationController
  include LoggingCommon

  before_action :init_service
  before_action :init_project_service, only: [:download]
  before_action :find_record

  def show
  end

  def download
    file_ids = params[:file_ids]
    project = Project.find(params[:project_id])
    if project.nil?
      project = @project_service.initialize_project
      unless project.save
        errors = project.errors.full_messages.join(', ')
        redirect_back fallback_location: root_path, alert: t('.error_generating_project', errors: errors)
        return
      end
    end

    download_files = @project_service.initialize_download_files(project, @record, file_ids)
    download_files.each do |file|
      unless file.valid?
        errors = file.errors.full_messages.join(', ')
        log_error('DownloadFile validation error', {error: errors, project_id: project.id, file: file.to_s})
        redirect_back fallback_location: root_path, alert: t('.invalid_file_in_selection', filename: file.filename, errors: errors)
        return
      end
    end

    save_results = download_files.map(&:save)
    if save_results.include?(false)
      redirect_back fallback_location: root_path, alert: t('.error_generating_the_download_file')
      return
    end

    redirect_back fallback_location: root_path, notice: t('.files_added_to_project', project_name: project.name)
  end

  private

  def init_service
    @service = Zenodo::RecordService.new
  end

  def init_project_service
    @project_service = Zenodo::ProjectService.new
  end

  def find_record
    @id = params[:id]
    @record = @service.find_record(@id)
    unless @record
      log_error('Record not found.', {id: @id})
      redirect_back fallback_location: root_path, alert: t('.record_not_found', id: @id)
    end
  rescue => e
    log_error('Zenodo service error', {id: @id}, e)
    redirect_back fallback_location: root_path, alert: t('.zenodo_service_error')
  end
end
