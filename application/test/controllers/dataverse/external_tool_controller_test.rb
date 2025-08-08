# frozen_string_literal: true
require 'test_helper'

class Dataverse::ExternalToolControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect with alert if dataverse_url is missing or invalid' do
    get integrations_dataverse_external_tool_dataset_path, params: { dataset_id: '123' }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.external_tool.dataset.invalid_request_error'), flash[:alert]
  end

  test 'should redirect with alert if dataset_id is missing' do
    get integrations_dataverse_external_tool_dataset_path, params: { dataverse_url: 'https://demo.dataverse.org' }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.external_tool.dataset.invalid_request_error'), flash[:alert]
  end

  test 'should redirect to dataset view with parsed dataverse_url' do
    get integrations_dataverse_external_tool_dataset_path, params: {
      dataverse_url: 'https://demo.dataverse.org:443',
      dataset_id: 'abc-123',
      version: '1.0',
      locale: 'en'
    }

    expected = explore_path(connector_type: ConnectorType::DATAVERSE.to_s, server_domain: 'demo.dataverse.org', object_type: 'datasets', object_id: 'abc-123')
    assert_redirected_to expected
  end

  test 'should redirect to dataset view with overrides' do
    get integrations_dataverse_external_tool_dataset_path, params: {
      dataverse_url: 'http://demo.dataverse.org:8080',
      dataset_id: 'abc-123',
      version: '1.0',
      locale: 'en'
    }

    expected = explore_path(connector_type: ConnectorType::DATAVERSE.to_s, server_domain: 'demo.dataverse.org', server_scheme: 'http', server_port: '8080', object_type: 'datasets', object_id: 'abc-123')
    assert_redirected_to expected
  end
end
