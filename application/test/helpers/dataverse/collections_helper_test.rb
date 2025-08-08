# frozen_string_literal: true
require 'test_helper'

class DataverseCollectionsHelperTest < ActionView::TestCase
  include Dataverse::CollectionsHelper

  setup do
    @controller.params = { dv_port: 443, dv_scheme: 'https' }
    @repo_url = Repo::RepoUrl.build('example.com')
  end

  test 'link_to_dataverse_collection delegates to explore helper' do
    expects(:link_to_explore).with(ConnectorType::DATAVERSE, @repo_url, type: 'collections', id: ':root').returns('/show')
    html = link_to_dataverse_collection('Body', @repo_url, ':root')
    assert_includes html, 'href="/show"'
  end

  test 'link_to_root_dataverse_collection uses :root identifier' do
    expects(:link_to_explore).with(ConnectorType::DATAVERSE, @repo_url, type: 'collections', id: ':root').returns('/root')
    html = link_to_root_dataverse_collection(@repo_url)
    assert_includes html, 'href="/root"'
  end

  test 'link_to_dataset delegates to dataset route helper' do
    stubs(:view_dataverse_dataset_url).with('example.com', 'id1', { dv_port: 443, dv_scheme: 'https' }).returns('/dataset')
    html = link_to_dataset('Ds', 'https://example.com', 'id1')
    assert_includes html, 'href="/dataset"'
  end

  test 'search_results_count summarizes range' do
    data = Dataverse::SearchResponse::Data.new({ start: 10, total_count: 40, items: [] }, 2, 10)
    result = OpenStruct.new(data: data)
    assert_equal '11 to 20 of 40 results', search_results_count(result)
  end

  test 'search_results_count out of range' do
    data = Dataverse::SearchResponse::Data.new({ start: 20, total_count: 5, items: [] }, 3, 10)
    result = OpenStruct.new(data: data)
    assert_equal 'Out of range', search_results_count(result)
  end

  test 'prev and next page links only when applicable' do
    data = Dataverse::SearchResponse::Data.new({ start: 10, total_count: 30, items: [], q: "term" }, 2, 10)
    result = OpenStruct.new(data: data)
    dataverse = OpenStruct.new(data: OpenStruct.new(alias: 'alias'))
    expects(:link_to_explore).with(ConnectorType::DATAVERSE, @repo_url, type: 'collections', id: 'alias').returns('/base')
    html = link_to_search_results_prev_page(@repo_url, dataverse, result, {})
    assert_includes html, 'href="/base?page=1&amp;query=term"'

    expects(:link_to_explore).with(ConnectorType::DATAVERSE, @repo_url, type: 'collections', id: 'alias').returns('/base')
    html = link_to_search_results_next_page(@repo_url, dataverse, result, {})
    assert_includes html, 'href="/base?page=3&amp;query=term"'
  end
end
