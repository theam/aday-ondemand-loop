require 'test_helper'

class UploadBundlesControllerTest < ActionDispatch::IntegrationTest
  include ModelHelper

  test 'create resolves repo and delegates to processor' do
    project = create_project
    project.save
    Project.stubs(:find).with(project.id.to_s).returns(project)
    ApplicationController.any_instance.stubs(:load_user_settings)

    resolver = mock('resolver')
    url_res = OpenStruct.new(type: ConnectorType::ZENODO, object_url: 'u', unknown?: false)
    resolver.stubs(:resolve).with('u').returns(url_res)
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    processor = mock('proc')
    processor.stubs(:params_schema).returns([:remote_repo_url])
    processor.stubs(:create).returns(ConnectorResult.new(resource: UploadBundle.new, message: {notice: 'ok'}, success: true))
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).with(ConnectorType::ZENODO).returns(processor)

    post project_upload_bundles_url(project.id), params: { remote_repo_url: 'u' }
    assert_response :redirect
  end


  test 'create redirects on invalid project' do
    Project.stubs(:find).returns(nil)
    post project_upload_bundles_url('1'), params: { remote_repo_url: 'u' }
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Invalid project id', flash[:alert]
  end

  test 'create handles unknown repo url' do
    project = create_project
    Project.stubs(:find).returns(project)
    resolver = mock('resolver')
    resolver.stubs(:resolve).with('u').returns(OpenStruct.new(unknown?: true))
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    post project_upload_bundles_url(project.id), params: { remote_repo_url: 'u' }
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'URL not supported', flash[:alert]
  end

  test 'edit renders partial' do
    bundle = create_upload_bundle(create_project)
    UploadBundle.stubs(:find).returns(bundle)
    processor = mock('proc')
    processor.stubs(:params_schema).returns([])
    processor.stubs(:edit).returns(ConnectorResult.new(partial: '/p', locals: {}))
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).returns(processor)
    UploadBundlesController.any_instance.stubs(:render).returns(true)
    get edit_project_upload_bundle_url('p', bundle.id, format: :html)
    assert_response :not_acceptable
  end

  test 'update redirects with processor result' do
    bundle = create_upload_bundle(create_project)
    UploadBundle.stubs(:find).returns(bundle)
    processor = mock('proc')
    processor.stubs(:params_schema).returns([])
    processor.stubs(:update).returns(ConnectorResult.new(message: {notice: 'ok'}))
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).returns(processor)
    patch project_upload_bundle_url('p', bundle.id)
    assert_redirected_to root_path
  end

  test 'destroy removes upload bundle' do
    project = create_project
    bundle = create_upload_bundle(project)
    UploadBundle.stubs(:find).with(project.id, bundle.id).returns(bundle)
    bundle.expects(:destroy)

    delete project_upload_bundle_url(project.id, bundle.id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Upload bundle deleted', flash[:notice]
  end

  test 'edit renders dataverse dataset create form partial' do
    project = create_project
    bundle = create_upload_bundle(project, type: ConnectorType::DATAVERSE)
    UploadBundle.stubs(:find).returns(bundle)
    processor = stub('proc', params_schema: [])
    result = ConnectorResult.new(
      partial: '/connectors/dataverse/dataset_create_form',
      locals: {
        upload_bundle: bundle,
        profile: OpenStruct.new(full_name: 'User', email: 'user@example.com'),
        subjects: []
      }
    )
    processor.stubs(:edit).returns(result)
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).with(ConnectorType::DATAVERSE).returns(processor)

    get edit_project_upload_bundle_url(project.id, bundle.id, form: 'dataset_create')

    assert_response :success
    assert_select 'form'
  end

  test 'edit renders dataverse dataset select form partial' do
    project = create_project
    bundle = create_upload_bundle(project, type: ConnectorType::DATAVERSE)
    UploadBundle.stubs(:find).returns(bundle)
    processor = stub('proc', params_schema: [])
    data = OpenStruct.new(total_count: 1, items: [OpenStruct.new(global_id: 'ds1', name: 'Dataset 1')])
    result = ConnectorResult.new(
      partial: '/connectors/dataverse/dataset_select_form',
      locals: { upload_bundle: bundle, data: data }
    )
    processor.stubs(:edit).returns(result)
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).with(ConnectorType::DATAVERSE).returns(processor)

    get edit_project_upload_bundle_url(project.id, bundle.id, form: 'dataset_select')

    assert_response :success
    assert_select 'input[type=radio][name=dataset_id]'
  end

  test 'edit renders dataverse collection select form partial' do
    project = create_project
    bundle = create_upload_bundle(project, type: ConnectorType::DATAVERSE)
    UploadBundle.stubs(:find).returns(bundle)
    processor = stub('proc', params_schema: [])
    data = OpenStruct.new(total_count: 1,
                          items: [OpenStruct.new(identifier: 'c1', name: 'Col1', parent_dataverse_name: 'Root')])
    result = ConnectorResult.new(
      partial: '/connectors/dataverse/collection_select_form',
      locals: { upload_bundle: bundle, data: data }
    )
    processor.stubs(:edit).returns(result)
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).with(ConnectorType::DATAVERSE).returns(processor)

    get edit_project_upload_bundle_url(project.id, bundle.id, form: 'collection_select')

    assert_response :success
    assert_select 'input[type=radio][name=collection_id]'
  end

  test 'edit renders zenodo connector edit form partial' do
    project = create_project
    bundle = create_upload_bundle(project, type: ConnectorType::ZENODO)
    bundle.metadata = { auth_key: 'abc' }
    UploadBundle.stubs(:find).returns(bundle)
    processor = stub('proc', params_schema: [])
    result = ConnectorResult.new(
      partial: '/connectors/zenodo/connector_edit_form',
      locals: { upload_bundle: bundle }
    )
    processor.stubs(:edit).returns(result)
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).with(ConnectorType::ZENODO).returns(processor)

    get edit_project_upload_bundle_url(project.id, bundle.id)

    assert_response :success
    assert_select 'input[name="api_key"]'
  end
end
