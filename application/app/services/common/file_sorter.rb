# frozen_string_literal: true

module Common
  class FileSorter
    include DateTimeCommon

    def most_relevant(files)
      files.sort_by do |file|
        [ status_priority(file.status), -to_time(file.creation_date).to_i ]
      end
    end

    private

    def status_priority(status)
      case
      when status.downloading? || status.uploading?
        0
      when status.pending?
        1
      when status.cancelled?
        2
      when status.error?
        3
      else
        4
      end
    end
  end
end
