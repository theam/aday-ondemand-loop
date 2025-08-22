# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

class Repo::RepoHistoryTest < ActiveSupport::TestCase
  def setup
    @tempfile = Tempfile.new('repo_history')
    @history = Repo::RepoHistory.new(db_path: @tempfile.path, max_entries: 2)
    @type = ConnectorType.get(:dataverse)
  end

  def teardown
    @tempfile.unlink
  end

  test 'add_repo stores entry and increments count' do
    @history.add_repo('https://demo.org', @type, { token: 'abc' })
    @history.add_repo('https://demo.org', @type, { token: 'xyz' })

    entry = @history.get('https://demo.org')
    assert entry
    assert_equal 2, entry.count
    assert_equal 'xyz', entry.metadata[:token]
  end

  test 'respects max_entries limit' do
    @history.add_repo('https://one.org', @type, {})
    @history.add_repo('https://two.org', @type, {})
    @history.add_repo('https://three.org', @type, {})

    assert_nil @history.get('https://one.org')
    assert_equal 2, @history.size
  end

  test 'persists and reloads from file' do
    @history.add_repo('https://demo.org', @type, { key: 'v' })

    reloaded = Repo::RepoHistory.new(db_path: @tempfile.path, max_entries: 2)
    entry = reloaded.get('https://demo.org')

    assert entry
    assert_equal 'v', entry.metadata[:key]
    assert_equal 1, entry.count
  end

  test 'entries are immutable and sorted by last_added' do
    first = @history.add_repo('https://one.org', @type, {})
    assert_raises(FrozenError) { first.count = 5 }

    sleep 1 # ensure timestamp ordering
    @history.add_repo('https://two.org', @type, {})

    assert_equal ['https://two.org', 'https://one.org'], @history.all.keys
  end
end
