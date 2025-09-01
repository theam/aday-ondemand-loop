require 'test_helper'

class ProjectEventListTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    @project = Project.new(id: 'proj1', name: 'Proj', download_dir: '/tmp/proj')
    @project.save
    @events_file = Project.events_file(@project.id)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'add appends event to file' do
    list = ProjectEventList.new(project_id: @project.id)
    list.add(entity_id: @project.id, entity_type: 'project', message: 'project has been created', metadata: { 'foo' => 'bar' })
    assert File.exist?(@events_file), 'events file not created'
    data = YAML.safe_load(File.read(@events_file))
    assert_equal 1, data.size
    assert_equal @project.id, data.last['entity_id']
  end

  test 'all returns stored events' do
    list = ProjectEventList.new(project_id: @project.id)
    list.add(entity_id: @project.id, entity_type: 'project', message: 'project has been created', metadata: {})
    events = ProjectEventList.new(project_id: @project.id).all
    assert_equal 1, events.size
    assert_equal @project.id, events.last.entity_id
    assert_equal 'project has been created', events.last.message
  end
end
