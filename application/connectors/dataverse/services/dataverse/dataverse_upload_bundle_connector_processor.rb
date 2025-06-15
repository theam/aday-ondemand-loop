# frozen_string_literal: true

class DataverseUploadBundleConnectorProcessor
  # Dataverse upload batch connector processor. Responsible for managing updates to collections of type Dataverse
    include LoggingCommon
    include DateTimeCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      %i[remote_repo_url form active_tab api_key key_scope collection_id dataset_id title description author contact_email subject]
    end

    def create(project, request_params)
      Actions::DataverseUploadBatchCreate.new.create(project, request_params)
    end

    def edit(upload_bundle, request_params)
      case request_params[:form].to_s
      when 'dataset_form_tabs'
        Actions::DataverseDatasetFormTabs.new.edit(upload_bundle, request_params)
      when 'dataset_create'
        Actions::DataverseDatasetCreate.new.edit(upload_bundle, request_params)
      when 'dataset_select'
        Actions::DataverseDatasetSelect.new.edit(upload_bundle, request_params)
      when 'collection_select'
        Actions::DataverseCollectionSelect.new.edit(upload_bundle, request_params)
      else
        Actions::DataverseConnectorEdit.new.edit(upload_bundle, request_params)
      end
    end

    def update(upload_bundle, request_params)
      case request_params[:form].to_s
      when 'dataset_form_tabs'
        Actions::DataverseDatasetFormTabs.new.update(upload_bundle, request_params)
      when 'dataset_create'
        Actions::DataverseDatasetCreate.new.update(upload_bundle, request_params)
      when 'dataset_select'
        Actions::DataverseDatasetSelect.new.update(upload_bundle, request_params)
      when 'collection_select'
        Actions::DataverseCollectionSelect.new.update(upload_bundle, request_params)
      else
        Actions::DataverseConnectorEdit.new.update(upload_bundle, request_params)
      end
    end

  end
end
