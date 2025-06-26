require 'test_helper'
require_relative '../../helpers/zenodo_helper'

class Zenodo::SearchResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  test 'parses items' do
    json = load_zenodo_fixture('search_response.json')
    resp = Zenodo::SearchResponse.new(json, 1, 2)
    assert_equal 2, resp.items.size
    assert_equal 'Record One', resp.items.first.title
    assert_equal '1', resp.items.first.id
    assert_equal 1, resp.page
    assert_equal 2, resp.per_page
    assert_equal 2, resp.total_count
    assert_equal 1, resp.total_pages
    assert resp.first_page?
    assert resp.last_page?
  end
end
