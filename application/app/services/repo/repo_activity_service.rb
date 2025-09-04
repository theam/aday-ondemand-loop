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

    def project_downloads(project_id)
      return [] if project_id.blank?

      project = Project.find_by(id: project_id)
      return [] unless project

      files = project.download_files
      Common::FileSorter.new.most_recent(files).map do |file|
        next unless file.connector_metadata&.files_url

        OpenStruct.new(
          type: file.type,
          date: file.creation_date,
          title: 'downloads',
          url: file.connector_metadata.files_url,
          note: 'dataset'
        )
      end.compact.uniq { |item| item.url }
    end
  end
end
