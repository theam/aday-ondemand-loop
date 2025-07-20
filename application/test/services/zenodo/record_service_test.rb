require 'test_helper'

class Zenodo::RecordServiceTest < ActiveSupport::TestCase
  include FileFixtureHelper

  def setup
    @client = HttpClientMock.new(file_path: fixture_path('zenodo/record_response.json'))
    @service = Zenodo::RecordService.new('https://zenodo.org', http_client: @client)
  end

  test 'find_record returns parsed record' do
    record = @service.find_record('11')
    assert_kind_of Zenodo::RecordResponse, record
    assert_equal '11', record.id
    assert_equal '/api/records/11', @client.called_path
  end

  test 'find_record returns nil when not found' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/record_response.json'), status_code: 404)
    service = Zenodo::RecordService.new('https://zenodo.org', http_client: client)
    assert_nil service.find_record('99')
  end

  test 'get_or_create_deposition returns deposition response' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/deposition_response.json'))
    service = Zenodo::RecordService.new('https://zenodo.org', http_client: client)
    dep = service.get_or_create_deposition('11', api_key: 'KEY')
    assert_instance_of Zenodo::DepositionResponse, dep
    assert_equal '/api/records/11/draft', client.called_path
  end

  test 'get_or_create_deposition handles not found' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/deposition_response.json'), status_code: 404)
    service = Zenodo::RecordService.new('https://zenodo.org', http_client: client)
    assert_nil service.get_or_create_deposition('11', api_key: 'KEY')
  end

  test 'get_or_create_deposition raises unauthorized' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/deposition_response.json'), status_code: 401)
    service = Zenodo::RecordService.new('https://zenodo.org', http_client: client)
    assert_raises(Zenodo::ApiService::UnauthorizedException) do
      service.get_or_create_deposition('11', api_key: 'KEY')
    end
  end
end
