class ProjectsController < ApplicationController
  include LoggingCommon
  include EventLogger

  def index
    @projects = Project.all
    @active_project = Project.find(Current.settings.user_settings.active_project.to_s)
  end

  def show
    @project = Project.find(params[:id])
    redirect_to projects_path, alert: t(".project_not_found", id: params[:id]) unless @project
  end

  def create
    project_name = params[:project_name] || ProjectNameGenerator.generate
    project = Project.new(id: project_name, name: project_name)
    if project.save
      log_project_event(project, message: 'events.project.created', metadata: { name: project.name, folder: project.download_dir })
      Current.settings.update_user_settings({ active_project: project.id.to_s })
      log_project_event(project, message: 'events.project.active', metadata: { name: project.name })
      notice = t(".project_created", project_name: project_name)
      if params.key?(:redirect_back)
        redirect_back fallback_location: projects_path, notice: notice
      else
        redirect_to project_path(id: project.id), notice: notice
      end
    else
      redirect_back fallback_location: projects_path, alert: t(".project_create_error", errors: project.errors.full_messages)
    end
  end

  def update
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      error_message = t(".project_not_found", id: project_id)
      respond_to do |format|
        format.html { redirect_back fallback_location: projects_path, alert: error_message }
        format.json { render json: { error: error_message }, status: :not_found }
      end
      return
    end

    update_params = params.permit(:name, :download_dir).to_h.compact

    if project.update(update_params)
      log_project_event(project, message: 'events.project.updated', metadata: { name: project.name, folder: project.download_dir })
      respond_to do |format|
        format.html { redirect_back fallback_location: projects_path, notice: t(".project_updated_successfully", project_name: project.name) }
        format.json { render json: project.to_json, status: :ok }
      end
      log_info('Project updated successfully', { project_id: project_id })
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: projects_path, alert: t(".project_update_error", errors: project.errors.full_messages) }
        format.json { render json: { error: project.errors.full_messages }, status: :unprocessable_entity }
      end
      log_error('Unable to update project', { project_id: project_id, errors: project.errors.full_messages })
    end
  end

  def set_active
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      error_message = t(".project_not_found", id: project_id)
      respond_to do |format|
        format.html { redirect_back fallback_location: projects_path, alert: error_message }
        format.json { render json: { error: error_message }, status: :not_found }
      end
      return
    end

    Current.settings.update_user_settings({active_project: project_id})
    log_project_event(project, message: 'events.project.active', metadata: { name: project.name })
    respond_to do |format|
      format.html { redirect_back fallback_location: projects_path, notice: t(".project_is_now_the_active_project", project_name: project.name) }
      format.json { render json: project.to_json, status: :ok }
    end
  end

  def destroy
    project_id = params[:id]
    project = Project.find(project_id)
    if project.nil?
      redirect_to projects_path, alert: t(".project_not_found", id: project_id)
      return
    end

    project.destroy
    redirect_to projects_path, notice: t(".project_deleted_successfully", project_name: project.name)
  end

end
