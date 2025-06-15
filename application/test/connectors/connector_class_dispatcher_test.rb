# frozen_string_literal: true
require 'test_helper'

class ConnectorClassDispatcherTest < ActiveSupport::TestCase

  test 'download_connector_status should return DataverseDownloadConnectorStatus class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_connector_status(project.download_files.first)
    assert_instance_of DataverseDownloadConnectorStatus, result
  end

  test 'upload_file_connector_status should return DataverseUploadConnectorStatus class for dataverse files' do
    project = upload_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.upload_file_connector_status(project.upload_bundles.first, project.upload_bundles.first.files.first)
    assert_instance_of DataverseUploadConnectorStatus, result
  end

  test 'download_connector_metadata should return DataverseDownloadConnectorMetadata class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_connector_metadata(project.download_files.first)
    assert_instance_of DataverseDownloadConnectorMetadata, result
  end

  test 'upload_bundle_connector_processor should return DataverseUploadBatchConnectorProcessor class for dataverse type' do
    result = ConnectorClassDispatcher.upload_bundle_connector_processor(ConnectorType::DATAVERSE)
    assert_instance_of DataverseUploadBundleConnectorProcessor, result
  end

  test 'upload_bundle_connector_metadata should return DataverseUploadBundleConnectorMetadata class for dataverse collections' do
    project = create_project
    upload_batch = create_upload_bundle(project, type: ConnectorType::DATAVERSE)
    result = ConnectorClassDispatcher.upload_bundle_connector_metadata(upload_batch)
    assert_instance_of DataverseUploadBundleConnectorMetadata, result
  end

  test 'download_processor should return DataverseDownloadConnectorProcessor class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_processor(project.download_files.first)
    assert_instance_of DataverseDownloadConnectorProcessor, result
  end

  test 'upload_processor should return DataverseUploadConnectorProcessor class for dataverse files' do
    project = upload_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.upload_processor(project.upload_bundles.first, project.upload_bundles.first.files.first)
    assert_instance_of DataverseUploadConnectorProcessor, result
  end

  test 'repo_controller_resolver should return DataverseDisplayRepoControllerResolver class for dataverse files' do
    result = ConnectorClassDispatcher.repo_controller_resolver(ConnectorType::DATAVERSE)
    assert_instance_of DataverseDisplayRepoControllerResolver, result
  end

  test 'raises ConnectorNotSupported for unknown connector type' do
    file = OpenStruct.new(type: :unknown)
    error = assert_raises(ConnectorClassDispatcher::ConnectorNotSupported) do
      ConnectorClassDispatcher.download_connector_status(file)
    end
    assert_match /Invalid connector type/, error.message
  end

end
