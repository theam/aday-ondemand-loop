# frozen_string_literal: true

module Repo
  class RepoActivityService

    # Returns global repository items from the RepoHistory store
    def global
      ::Configuration.repo_history.all.map do |entry|
        OpenStruct.new(
          type: entry.type,
          date: entry.last_added,
          title: entry.title || entry.repo_url,
          url: entry.repo_url,
          note: entry.note
        )
      end
    end

    def project_download_repos(project_id)
      return [] if project_id.blank?

      project = Project.find_by(id: project_id)
      return [] unless project

      files = project.download_files
      Common::FileSorter.new.most_recent(files).map do |file|
        file.connector_metadata.files_url
      end.compact.uniq
    end
  end
end
