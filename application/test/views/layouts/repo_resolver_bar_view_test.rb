# frozen_string_literal: true

require 'test_helper'

class RepoResolverBarViewTest < ActionView::TestCase
  test 'defaults url to repo_resolver_path' do
    html = render partial: 'layouts/repo_resolver_bar', locals: { show_images: false }
    assert_includes html, "action=\"#{repo_resolver_path}\""
  end

  test 'allows overriding url' do
    custom_url = '/custom/path'
    html = render partial: 'layouts/repo_resolver_bar', locals: { url: custom_url, show_images: false }
    assert_includes html, "action=\"#{custom_url}\""
  end
end
