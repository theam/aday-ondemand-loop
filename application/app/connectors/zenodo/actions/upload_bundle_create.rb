module Zenodo::Actions
  class UploadBundleCreate
    include LoggingCommon
    include DateTimeCommon

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      url_data = Zenodo::ZenodoUrl.parse(remote_repo_url)
      log_info('Zenodo URL data', {data: url_data.inspect})

      if url_data.record?
        records_service = Zenodo::RecordService.new(url_data.zenodo_url)
        record = records_service.find_record(url_data.record_id)
        return error(I18n.t('connectors.zenodo.actions.upload_bundles.record_not_found', url: remote_repo_url)) unless record

        record_title = record.title
      end

      file_utils = Common::FileUtils.new
      upload_bundle = UploadBundle.new.tap do |bundle|
        bundle.id = file_utils.normalize_name(File.join(url_data.domain, UploadBundle.generate_code))
        bundle.name = bundle.id
        bundle.project_id = project.id
        bundle.remote_repo_url = remote_repo_url
        bundle.type = ConnectorType::ZENODO
        bundle.creation_date = now
        bundle.metadata = {
          server_domain: url_data.domain,
          zenodo_url: url_data.zenodo_url,
          record_title: record_title,
          record_id: url_data.record_id
        }
      end
      upload_bundle.save

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.zenodo.actions.upload_bundles.created', name: upload_bundle.name) },
        success: true
      )
    end

    private

    def error(message)
      ConnectorResult.new(
        message: { alert: message },
        success: false
      )
    end
  end
end