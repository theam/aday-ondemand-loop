module Zenodo
  class ProjectService
    include LoggingCommon
    include DateTimeCommon

    def initialize(api_url = 'https://zenodo.org/api', file_utils: Common::FileUtils.new)
      @api_url = api_url
      @file_utils = file_utils
    end

    def initialize_project
      name = ProjectNameGenerator.generate
      Project.new(id: name, name: name)
    end

    def initialize_download_files(project, record, file_ids)
      ids = Array(file_ids).map(&:to_s)
      selected = record.files.select { |f| ids.include?(f.id.to_s) }
      selected.map do |file|
        DownloadFile.new.tap do |fobj|
          fobj.id = DownloadFile.generate_id
          fobj.project_id = project.id
          fobj.creation_date = now
          fobj.type = ConnectorType::ZENODO
          fobj.filename = File.join('/', file.filename)
          fobj.status = FileStatus::PENDING
          fobj.size = file.filesize
          fobj.metadata = {
            zenodo_url: @api_url.sub('/api',''),
            record_id: record.id,
            id: file.id.to_s,
            md5: file.checksum,
            download_url: file.download_url,
            download_location: nil,
            temp_location: nil
          }
          @file_utils.make_download_file_unique(fobj)
        end
      end
    end
  end
end
