require 'test_helper'

class ZenodoExploreHelperTest < ActionView::TestCase
  include Zenodo::ExploreHelper

  def setup
    @repo_url = OpenStruct.new(domain: 'zenodo.org', scheme_override: nil, port_override: nil)
  end

  test 'link_to_explore builds path' do
    stubs(:explore_path).with(connector_type: ConnectorType::ZENODO.to_s,
                               server_domain: 'zenodo.org',
                               server_scheme: nil,
                               server_port: nil,
                               object_type: 'records',
                               object_id: '1').returns('/explore')
    assert_equal '/explore', link_to_explore(@repo_url, type: 'records', id: '1')
  end

  test 'prev and next links rendered when pages available' do
    page = Page.new((1..30).to_a, 2, 10)
    stubs(:explore_path).returns('/link')
    html = link_to_explore_prev_page('q', page, @repo_url, {})
    assert_includes html, '/link'
    html = link_to_explore_next_page('q', page, @repo_url, {})
    assert_includes html, '/link'
  end

  test 'prev returns nil on first page' do
    page = Page.new((1..10).to_a, 1, 10)
    assert_nil link_to_explore_prev_page('q', page, @repo_url, {})
  end

  test 'next returns nil on last page' do
    page = Page.new((1..10).to_a, 1, 10)
    assert_nil link_to_explore_next_page('q', page, @repo_url, {})
  end
end
