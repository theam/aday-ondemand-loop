# frozen_string_literal: true
require 'test_helper'
require 'tempfile'

class Repo::RepoHistoryTest < ActiveSupport::TestCase
  def setup
    @tempfile = Tempfile.new('repo_history')
    @history = Repo::RepoHistory.new(history_path: @tempfile.path)
    @type = ConnectorType::DATAVERSE
  end

  def teardown
    @tempfile.unlink
  end

  test 'add persists entry' do
    entry = @history.add(object_url: 'https://demo.org', type: @type)
    assert_equal 'https://demo.org', entry.object_url
    assert_equal @type, entry.type
    assert_empty entry.metadata.to_h

    reloaded = Repo::RepoHistory.new(history_path: @tempfile.path)
    assert_equal 1, reloaded.size
    r = reloaded.all.first
    assert_equal 'https://demo.org', r.object_url
    assert_equal @type, r.type
  end

  test 'find_by_object_url returns matching entry' do
    @history.add(object_url: ' https://demo.org ', type: @type)
    found = @history.find_by_object_url('https://demo.org')
    assert found
    assert_equal 'https://demo.org', found.object_url
  end

  test 'entries are added to the beginning' do
    @history.add(object_url: 'https://first.org', type: @type)
    @history.add(object_url: 'https://second.org', type: @type)
    urls = @history.all.map(&:object_url)
    assert_equal ['https://second.org', 'https://first.org'], urls
  end

  test 'limits number of stored entries' do
    limited = Repo::RepoHistory.new(history_path: @tempfile.path, max_entries: 2)
    limited.add(object_url: 'https://1.org', type: @type)
    limited.add(object_url: 'https://2.org', type: @type)
    limited.add(object_url: 'https://3.org', type: @type)

    urls = limited.all.map(&:object_url)
    assert_equal ['https://3.org', 'https://2.org'], urls
  end
end
