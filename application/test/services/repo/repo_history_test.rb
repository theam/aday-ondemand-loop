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
end
