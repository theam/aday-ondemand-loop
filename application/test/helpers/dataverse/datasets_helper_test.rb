# frozen_string_literal: true
require 'test_helper'

class DataverseDatasetsHelperTest < ActionView::TestCase
  include Dataverse::DatasetsHelper

  test 'file_thumbnail uses dataverse preview for images' do
    json = load_dataverse_fixture('dataset_files_response', 'valid_response.json')
    file = Dataverse::DatasetFilesResponse.new(json).files.first
    html = file_thumbnail('https://dv.example', file)
    assert_includes html, 'src="https://dv.example/api/access/datafile/'
  end

  test 'file_thumbnail uses placeholder for other types' do
    file_hash = { label: 'a', dataFile: { id: 1, filename: 'a.txt', contentType: 'text/plain' } }
    file = Dataverse::DatasetFilesResponse::DatasetFile.new(file_hash)
    html = file_thumbnail('https://dv.example', file)
    assert_includes html, 'file_thumbnail.png'
  end

  test 'verify methods delegate to service' do
    service = mock('svc')
    service.expects(:validate_dataset).with(:d).returns(:ok)
    service.expects(:validate_dataset_file).with(:f).returns(:ok2)
    stubs(:retrictions_service).returns(service)
    assert_equal :ok, verify_dataset(:d)
    assert_equal :ok2, verify_file(:f)
  end

  test 'link_to_dataset_prev_page and next_page' do
    page = Page.new((1..30).to_a, 2, 10)
    stubs(:view_dataverse_dataset_path).returns('/prev')
    html = link_to_dataset_prev_page('https://dv.example', 'id', '1.0', page, {})
    assert_includes html, '/prev'

    page = Page.new((1..30).to_a, 2, 10)
    stubs(:view_dataverse_dataset_path).returns('/next')
    html = link_to_dataset_next_page('https://dv.example', 'id', '1.0', page, {})
    assert_includes html, '/next'
  end

  test 'storage_identifier parses identifier' do
    assert_equal 's3://bucket', storage_identifier('s3://bucket:12345')
    assert_nil storage_identifier(nil)
  end

  test 'dataverse_dataset_view_url builds path with overrides' do
    stubs(:view_dataverse_dataset_path).with('host', 'pid', { dv_port: 8080, dv_scheme: 'http', version: '1.0', page: 2, query: 'q' }).returns('/view')
    url = dataverse_dataset_view_url('http://host:8080', 'pid', version: '1.0', page: 2, query: 'q')
    assert_equal '/view', url
  end

  test 'dataset_versions_url uses params for overrides' do
    stubs(:params).returns({ dv_port: '1234', dv_scheme: 'http' })
    stubs(:view_dataverse_dataset_versions_path).with('host', 'pid', { dv_port: '1234', dv_scheme: 'http' }).returns('/versions')
    url = dataset_versions_url('http://host', 'pid')
    assert_equal '/versions', url
  end

  test 'external_dataset_url builds correct link' do
    url = external_dataset_url('http://dv.example', 'pid', '1.0')
    assert_equal 'http://dv.example/dataset.xhtml?persistentId=pid&version=1.0', url
  end

  test 'sort_by_draft orders drafts first' do
    list = [OpenStruct.new(version: '1'), OpenStruct.new(version: ':draft'), OpenStruct.new(version: '2')]
    sorted = sort_by_draft(list)
    assert_equal ':draft', sorted.first.version
  end
end
