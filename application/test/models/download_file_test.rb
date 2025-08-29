require 'test_helper'

# TODO: Review validation with David
class DownloadFileTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    @valid_attributes = {
      'id' => '123-321', 'project_id' => '456-789', 'type' => ConnectorType::DATAVERSE, 'filename' => 'test.png',
      'status' => FileStatus::PENDING, 'size' => 1024,
      'creation_date' => nil,
      'start_date' => nil,
      'end_date' => nil,
      'metadata' => {
        'id' => '',
        'filename' => '',
        'size' => '',
        'content_type' => '',
      }
    }
    @download_file = DownloadFile.new(@valid_attributes)
    @expected_filename = File.join(Project.download_files_directory('456-789'), '123-321.yml')
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'should initialize with valid attributes' do
    assert_equal '123-321', @download_file.id
    assert_equal '456-789', @download_file.project_id
    assert_equal ConnectorType::DATAVERSE, @download_file.type
    assert_equal 'test.png', @download_file.filename
    assert_equal FileStatus::PENDING, @download_file.status
    assert_equal 1024, @download_file.size
  end

  test 'should be valid' do
    assert @download_file.valid?
  end

  test 'should be invalid because of invalid values' do
    assert @download_file.valid?
    @download_file.size = -1
    refute @download_file.valid?
    assert_includes @download_file.errors[:size], 'must be greater than or equal to 0'
  end

  test 'should validate max file size' do
    assert @download_file.valid?
    @download_file.size = 11.gigabytes
    refute @download_file.valid?
    assert_includes @download_file.errors[:size], 'is too large (maximum allowed is 10 GB)'
  end

  test 'to_h' do
    expected_hash = map_objects(@valid_attributes)
    assert_equal expected_hash, @download_file.to_h
  end

  test 'to_json' do
    expected_json = map_objects(@valid_attributes).to_json
    assert_equal expected_json, @download_file.to_json
  end

  test 'to_yaml' do
    expected_yaml = map_objects(@valid_attributes).to_yaml
    assert_equal expected_yaml, @download_file.to_yaml
  end

  test 'save with valid attributes' do
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'save twice only creates one file' do
    files_directory = Pathname.new(Project.download_files_directory('456-789'))
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
  end

  test 'save stopped due to invalid attributes' do
    @download_file.size = 'invalid_type'
    refute @download_file.save
    refute File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'find does not find the record if it was not saved' do
    refute DownloadFile.find('456-789', '123-321')
  end

  test 'find retrieves the record if it was saved' do
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert DownloadFile.find('456-789', '123-321')
  end

  test 'find retrieves the record with the same stored values' do
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    loaded_file = DownloadFile.find('456-789', '123-321')
    assert loaded_file
    assert_equal '123-321', loaded_file.id
    assert_equal '456-789', loaded_file.project_id
    assert_equal ConnectorType::DATAVERSE, loaded_file.type
    assert_equal 'test.png', loaded_file.filename
    assert_equal FileStatus::PENDING, loaded_file.status
    assert_equal 1024, loaded_file.size
  end

  test 'find retrieves the record only if both ids match' do
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert DownloadFile.find('456-789', '123-321')
    refute DownloadFile.find('456-780', '123-321')
    refute DownloadFile.find('456-789', '123-322')
  end

  test 'update' do
    project = create_project
    target = create_download_file(project)
    target.update(status: FileStatus::CANCELLED)
    assert_equal FileStatus::CANCELLED, target.status
  end

  def map_objects(hash)
    hash['type'] = hash['type'].to_s
    hash['status'] = hash['status'].to_s
    hash
  end
end