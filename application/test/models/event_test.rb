require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    @project = Project.new(id: 'proj1', name: 'Proj', download_dir: '/tmp/proj')
    @project.save
    @event = Event.new(project_id: @project.id, id: 'evt1', type: EventType::GENERIC, metadata: { 'foo' => 'bar' }, creation_date: DateTimeCommon.now)
    @events_file = Project.events_file(@project.id)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'save appends event to file' do
    assert @event.save
    assert File.exist?(@events_file), 'events file not created'
    data = YAML.safe_load(File.read(@events_file))
    assert_equal 2, data.size
    assert_equal 'evt1', data.last['id']
  end

  test 'for_project returns stored events' do
    @event.save
    events = Event.for_project(@project.id)
    assert_equal 2, events.size
    assert_equal 'evt1', events.last.id
    assert_equal EventType::GENERIC, events.last.type
  end

  test 'for_project handles legacy hash file' do
    FileUtils.mkdir_p(File.dirname(@events_file))
    File.open(@events_file, 'w') { |f| f.write(@event.to_h.to_yaml) }
    events = Event.for_project(@project.id)
    assert_equal 1, events.size
    assert_equal 'evt1', events.first.id
  end

  test 'download file created event sets type and metadata' do
    event = Events::DownloadFileCreated.new(project_id: @project.id, file_id: 'f1', filename: 'test.txt', file_size: 10)
    assert_equal EventType::DOWNLOAD_FILE_CREATED, event.type
    assert_equal 'f1', event.metadata['file_id']
    assert_equal 'test.txt', event.metadata['filename']
  end

  test 'project created event sets type and metadata' do
    event = Events::ProjectCreated.new(project_id: @project.id, project_name: 'Proj')
    assert_equal EventType::PROJECT_CREATED, event.type
    assert_equal 'Proj', event.metadata['project_name']
    assert_equal 1, event.metadata.size
  end

  test 'project updated event sets type and metadata' do
    event = Events::ProjectUpdated.new(project_id: @project.id, project_name: 'Proj')
    assert_equal EventType::PROJECT_UPDATED, event.type
    assert_equal 'Proj', event.metadata['project_name']
    assert_equal 1, event.metadata.size
  end
end
