module StatusHelper

  def cancel_button_disabled?(status)
    FileStatus.completed_statuses.include?(status)
  end

  def retry_button_visible?(file)
    file.restart_possible?
  end
end
