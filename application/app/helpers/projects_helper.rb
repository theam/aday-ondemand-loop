module ProjectsHelper

  def active_project?(project_id)
    Current.settings.user_settings.active_project.to_s == project_id
  end

  def select_project_list_name(project)
    return project.name unless active_project?(project.id.to_s)
    "#{project.name} (#{t('helpers.projects.active_project_text')})"
  end

  # frozen_string_literal: true

  def select_project_list
    current_id = Current.from_project.to_s
    active_id =  Current.settings.user_settings.active_project.to_s
    current = []
    active  = []
    others  = []

    Project.all.each do |project|
      pid = project.id.to_s
      if pid == current_id
        current << project
      elsif pid == active_id
        active << project
      else
        others << project
      end
    end

    current + active + others
  end

  def project_header_class(active)
    active ? 'bg-primary-subtle' : 'bg-body-secondary'
  end

  def project_border_class(active)
    active ? 'border-primary-subtle' : ''
  end

  def project_progress_data(file_status_count, title = '')
    pending = file_status_count.pending.to_i
    in_progress = file_status_count.downloading.to_i + file_status_count.uploading.to_i
    completed = file_status_count.success.to_i
    cancelled = file_status_count.cancelled.to_i
    error = file_status_count.error.to_i
    {
      id: SecureRandom.uuid,
      title: title,
      pending: pending,
      in_progress: in_progress,
      completed: completed,
      cancelled: cancelled,
      error: error,
      total: file_status_count.total
    }
  end

  def project_download_dir_browser_id(project)
    "download-dir-browser-#{project.id}"
  end

end
