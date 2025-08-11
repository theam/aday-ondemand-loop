module StatusHelper

  def cancel_button_disabled?(status)
    FileStatus.completed_statuses.include?(status)
  end

  def retry_button_visible?(file)
    FileStatus.retryable_statuses.include?(file.status) && file.connector_metadata.restart_possible
  end
end
