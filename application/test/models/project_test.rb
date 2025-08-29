require "test_helper"

class ProjectTest < ActiveSupport::TestCase

  test "initialization should works" do
    target = Project.new(id: 'ab12345', name: 'test_project', download_dir: '/tmp/test_project')
    assert_equal 'ab12345', target.id
    assert_equal 'test_project', target.name
    assert_equal '/tmp/test_project', target.download_dir
    assert_not_nil target.creation_date
  end

  test "should be valid when all fields are populated" do
    target = create_valid_project
    assert target.valid?
  end

  test "validations should fail due to blank value" do
    target = create_valid_project
    assert target.valid?

    target.id = ''
    refute target.valid?
    assert_includes target.errors[:id], "can't be blank"

    target.name = ''
    refute target.valid?
    assert_includes target.errors[:name], "can't be blank"

    target.download_dir = ''
    refute target.valid?
    assert_includes target.errors[:download_dir], "can't be blank"

    target.creation_date = ''
    refute target.valid?
    assert_includes target.errors[:creation_date], "can't be blank"
  end

  test "to_h" do
    target = create_valid_project
    expected_hash = project_hash(target)
    assert_equal expected_hash, target.to_h
  end

  test "to_json" do
    target = create_valid_project
    expected_json = project_hash(target).to_json
    assert_equal expected_json, target.to_json
  end

  test "to_yaml" do
    target = create_valid_project
    expected_yaml = project_hash(target).stringify_keys.to_yaml
    assert_equal expected_yaml, target.to_yaml
  end

  test "save with valid attributes" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      expected_file = File.join(dir, 'projects', target.id, 'metadata.yml')
      assert File.exist?(expected_file), "Project file was not created in the file system"
    end
  end

  test "save twice only creates one file" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      expected_directory = File.join(dir, 'projects', target.id)
      expected_file = File.join(expected_directory, 'metadata.yml')
      assert File.exist?(expected_file), "Project file was not created in the file system"
      assert_equal 1, Dir.glob(expected_directory).count

      assert target.save
      assert File.exist?(expected_file), "Project file was not created in the file system"
      assert_equal 1, Dir.glob(expected_directory).count
    end
  end

  test "save stopped due to invalid attributes" do
    in_temp_directory do |dir|
      target = create_valid_project
      target.id = ''
      refute target.save
      expected_file = File.join(dir, 'projects', target.id, 'metadata.yml')
      refute File.exist?(expected_file), "Project file was created in the file system"
    end
  end

  test "find does not find the record if it was not saved" do
    refute Project.find('456-789')
  end

  test "find retrieves the record if it was saved" do
    in_temp_directory do |dir|
      target = create_valid_project
      target.save
      assert Project.find(target.id)
    end
  end

  test "find retrieves the record with the same stored values" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      saved_project = Project.find(target.id)
      assert saved_project
      assert_equal 'ab12345', saved_project.id
      assert_equal 'test_project', saved_project.name
      assert_equal '/tmp/test_project', saved_project.download_dir
    end
  end

  test "find retrieves the correct record on multiple records" do
    in_temp_directory do |dir|
      target1 = create_valid_project(id: random_id, name: random_id)
      assert target1.save

      target2 = create_valid_project(id: random_id, name: random_id)
      assert target2.save

      target3 = create_valid_project(id: random_id, name: random_id)
      assert target3.save

      saved_project = Project.find(target2.id)
      assert saved_project
      assert_equal target2.id, saved_project.id
      assert_equal target2.name, saved_project.name
      assert_equal target2.download_dir, saved_project.download_dir
    end
  end

  test "all returns empty array if no records stored" do
    in_temp_directory do
      assert Project.all.empty?
    end
  end

  test "all returns an array with the saved entry" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      assert_equal 1, Project.all.size
      saved_project = Project.all.first
      assert saved_project
      assert_equal 'ab12345', saved_project.id
      assert_equal 'test_project', saved_project.name
      assert_equal '/tmp/test_project', saved_project.download_dir
    end
  end

  test "all returns an array with multiple entries sorted by creation date descendant" do
    in_temp_directory do |dir|
      target1 = create_valid_project(id: random_id, name: random_id)
      assert target1.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE

      target2 = create_valid_project(id: random_id, name: random_id)
      assert target2.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE
      target3 = create_valid_project(id: random_id, name: random_id)
      assert target3.save

      projects = Project.all
      assert 3, projects.size
      assert_equal target3.id, projects[0].id
      assert_equal target2.id, projects[1].id
      assert_equal target1.id, projects[2].id
    end
  end

  test "files default value is empty array" do
    in_temp_directory do
      target = create_valid_project
      assert target.save
      saved_project = Project.find(target.id)
      assert saved_project.download_files.empty?
    end
  end

  test "files handle a single file" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      file = create_download_file(target)
      assert file.save, file
      expected_file = File.join(dir, 'projects', target.id, 'download_files', "#{file.id}.yml")
      assert File.exist?(expected_file)

      saved_project = Project.find(target.id)
      project_files = saved_project.download_files
      assert_equal 1, project_files.count
      saved_file = project_files.first
      assert_equal file.id, saved_file.id
    end
  end

  test "files handle multiple files sorted by creation date descendent" do
    in_temp_directory do
      target = create_valid_project
      target.save
      file1 = create_download_file(target, id: 'saved_1')
      file1.creation_date = (Time.now - 120).strftime('%Y-%m-%dT%H:%M:%S')
      assert file1.save
      file2 = create_download_file(target, id: 'saved_2')
      file2.creation_date = (Time.now - 60).strftime('%Y-%m-%dT%H:%M:%S')
      assert file2.save
      file3 = create_download_file(target, id: 'saved_3')
      file3.creation_date = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
      assert file3.save

      saved_project = Project.find(target.id)
      project_files = saved_project.download_files
      assert_equal 3, project_files.count
      assert_equal file3.id, project_files[0].id
      assert_equal file2.id, project_files[1].id
      assert_equal file1.id, project_files[2].id
    end
  end

  test "saving project logs ProjectCreated event with matching timestamp" do
    in_temp_directory do
      target = create_valid_project
      creation = target.creation_date
      assert target.save
      saved_project = Project.find(target.id)
      events = saved_project.events
      assert_equal 1, events.count
      event = events.first
      assert_equal 'project_created', event.type
      assert_equal creation, event.creation_date
      assert_equal target.name, event.metadata['name']
    end
  end

  test "events handle a single additional event" do
    in_temp_directory do
      target = create_valid_project
      assert target.save
      event = Event.new(project_id: target.id, id: 'evt1', type: 'project_created', entity_type: 'project', metadata: {})
      assert event.save

      saved_project = Project.find(target.id)
      project_events = saved_project.events
      assert_equal 2, project_events.count
      assert_equal 'evt1', project_events.last.id
      assert_equal 'project_created', project_events.first.type
    end
  end

  test "saving events creates file and loads them" do
    in_temp_directory do
      project = create_valid_project
      assert project.save

      evt1 = Event.new(project_id: project.id, id: 'evt1', type: 'project_created', entity_type: 'project', metadata: {})
      evt2 = Event.new(project_id: project.id, id: 'evt2', type: 'project_updated', entity_type: 'project', metadata: {})
      assert evt1.save
      assert evt2.save

      events_path = Project.events_file(project.id)
      assert File.exist?(events_path), 'events file was not created'

      saved_project = Project.find(project.id)
      loaded_events = saved_project.events
      assert_equal 3, loaded_events.count
      assert_equal %w[evt1 evt2], loaded_events.last(2).map(&:id)
    end
  end

  test "update download_dir fails when files pending or downloading" do
    in_temp_directory do |dir|
      project = create_valid_project
      project.save
      file = create_download_file(project)
      file.save

      saved_project = Project.find(project.id)
      new_dir = File.join(dir, 'new_download')
      FileUtils.mkdir_p(new_dir)
      refute saved_project.update(download_dir: new_dir)
      assert_equal project.download_dir, saved_project.download_dir
      assert_match /cannot be updated/, saved_project.errors[:download_dir].first
    end
  end

  test "update download_dir fails when new directory invalid" do
    in_temp_directory do
      project = create_valid_project
      project.save

      saved_project = Project.find(project.id)
      refute saved_project.update(download_dir: '/does/not/exist')
      assert_match /parent directory must exist and be writable/, saved_project.errors[:download_dir].first
      assert_equal project.download_dir, saved_project.download_dir
    end
  end

  test "update download_dir succeeds when no active downloads" do
    in_temp_directory do |dir|
      project = create_valid_project
      project.save
      file = create_download_file(project)
      file.status = FileStatus::SUCCESS
      file.save

      saved_project = Project.find(project.id)
      new_dir = File.join(dir, 'new_download')
      FileUtils.mkdir_p(new_dir)
      assert saved_project.update(download_dir: new_dir)
      assert_equal new_dir, saved_project.download_dir
    end
  end

  private

  def create_valid_project(id: 'ab12345', name: 'test_project', download_dir: '/tmp/test_project')
    Project.new(id: id, name: name, download_dir: download_dir)
  end

  def project_hash(project)
    {id: project.id, name: project.name, download_dir: project.download_dir, creation_date: project.creation_date}.stringify_keys
  end

  def in_temp_directory
    Dir.mktmpdir do |dir|
      Project.stubs(:metadata_root_directory).returns(dir)
      DownloadFile.stubs(:metadata_root_directory).returns(dir)

      yield dir
    end
  end

end

