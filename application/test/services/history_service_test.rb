# frozen_string_literal: true

require 'test_helper'

class HistoryServiceTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project

    @file1 = create_download_file(@project)
    @file1.creation_date = '2024-01-01T00:00:00'
    @file1.stubs(:connector_metadata).returns(OpenStruct.new(files_url: '/file1'))

    @file2 = create_download_file(@project)
    @file2.creation_date = '2024-01-02T00:00:00'
    @file2.stubs(:connector_metadata).returns(OpenStruct.new(files_url: '/file2'))

    @file3 = create_download_file(@project)
    @file3.creation_date = '2024-01-03T00:00:00'
    @file3.stubs(:connector_metadata).returns(OpenStruct.new(files_url: '/file2'))

    @project.stubs(:download_files).returns([@file1, @file2, @file3])
    Project.stubs(:find).with(@project.id).returns(@project)
  end

  test 'summary returns unique items ordered by recency' do
    result = HistoryService.new.summary(@project.id)

    assert_equal ['/file2', '/file1'], result.recent.map(&:url)
    assert_equal result.recent, result.popular

    first = result.recent.first
    assert_equal '2024-01-03T00:00:00', first.date
    assert_equal 'published', first.version
    assert_equal '/file2', first.title
    assert_equal '/file2', first.explore_url
  end
end
