require 'test_helper'

class TraceTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    Trace.stubs(:metadata_root_directory).returns(@tmp_dir)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'add and find trace for project' do
    trace = Trace.add(entity_type: 'project', entity_ids: ['p1'], message: 'created')
    file = Trace.filename('project', ['p1'], trace.id)
    assert File.exist?(file)

    loaded = Trace.find('project', ['p1'], trace.id)
    assert_equal trace.message, loaded.message
    assert_equal trace.entity_type, loaded.entity_type
  end

  test 'list traces for project ordered by creation date' do
    Trace.add(entity_type: 'project', entity_ids: ['p1'], message: 'a')
    sleep 1
    Trace.add(entity_type: 'project', entity_ids: ['p1'], message: 'b')

    traces = Trace.all('project', ['p1'])
    assert_equal 2, traces.size
    assert_equal 'b', traces.first.message
  end
end
