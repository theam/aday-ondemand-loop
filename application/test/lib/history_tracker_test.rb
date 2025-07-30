# frozen_string_literal: true
require 'test_helper'
require 'tempfile'

class HistoryTrackerTest < ActiveSupport::TestCase
  def setup
    @tmp = Tempfile.new('history')
    @tracker = HistoryTracker.new(file_path: @tmp.path, max_per_type: 3, save_interval: 0)
  end

  def teardown
    @tmp.unlink
  end

  test 'add and get maintains MRU order' do
    @tracker.add(:project, 'a')
    @tracker.add(:project, 'b')
    @tracker.add(:project, 'a')

    assert_equal ['a', 'b'], @tracker.get(:project)
  end

  test 'enforces max_per_type' do
    %w[a b c d].each { |v| @tracker.add(:project, v) }
    assert_equal ['d', 'c', 'b'], @tracker.get(:project)
  end

  test 'persists and reloads history' do
    @tracker.add(:project, 'x')
    @tracker.flush

    tracker2 = HistoryTracker.new(file_path: @tmp.path, max_per_type: 3)
    assert_equal ['x'], tracker2.get(:project)
  end

  test 'handles invalid yaml gracefully' do
    File.write(@tmp.path, "invalid: [")
    tracker = HistoryTracker.new(file_path: @tmp.path)
    assert_nothing_raised { tracker.get(:project) }
    assert_equal [], tracker.get(:project)
  end
end
