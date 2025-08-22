# frozen_string_literal: true

require 'ostruct'

class HistoryService
  include DateTimeCommon

  def summary(project_id)
    project = Project.find(project_id)
    return OpenStruct.new(recent: [], popular: []) unless project

    files = Common::FileSorter.new.most_recent(project.download_files)

    items = files.map do |file|
      url = file.connector_metadata&.files_url
      next if url.nil? || url.empty?

      OpenStruct.new(
        date: file.creation_date,
        title: url,
        url: url,
        explore_url: url,
        version: 'published'
      )
    end.compact

    items = items.uniq { |item| item.url }
    OpenStruct.new(recent: items, popular: items)
  end
end
