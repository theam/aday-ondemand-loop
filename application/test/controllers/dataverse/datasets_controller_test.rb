require "test_helper"

class DataverseDatasetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    @new_id = SecureRandom.uuid.to_s
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  def dataset_valid_json
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'valid_response.json'))
  end

  def dataset_incomplete_json_no_data
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_data.json'))
  end

  def dataset_incomplete_json_no_metadata_blocks
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_metadata_blocks.json'))
  end

  def dataset_incomplete_json_no_license
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_license.json'))
  end

  def files_valid_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response.json'))
  end

  def files_incomplete_no_data_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'incomplete_no_data.json'))
  end

  def files_incomplete_no_data_file_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'incomplete_no_data_file.json'))
  end

  test "should redirect to root path after not finding a dataverse host" do
    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises("error")
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises("error")
    get view_dataverse_dataset_url("random", "random_id")
    assert_redirected_to root_path
    assert_equal "Dataverse service error. Dataverse: https://random persistentId: random_id", flash[:alert]
  end

  test "should redirect to root path after not finding a dataset" do
    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(nil)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to root_path
    assert_equal "Dataset not found. Dataverse: https://#{@new_id} persistentId: random_id", flash[:alert]
  end

  test "should redirect to root path after raising exception" do
    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises("error")
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to root_path
    assert_equal "Dataverse service error. Dataverse: https://#{@new_id} persistentId: random_id", flash[:alert]
  end

  test "should redirect to root path after raising Unauthorized exception" do
    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises(DataverseDatasetService::UnauthorizedException)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(DataverseDatasetService::UnauthorizedException)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to root_path
    assert_equal "Dataset requires authorization. Dataverse: https://#{@new_id} persistentId: random_id", flash[:alert]
  end

  test "should redirect to root path after raising Unauthorized exception only in files page" do
    dataset = DataverseDatasetVersionResponse.new(dataset_valid_json)
    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(DataverseDatasetService::UnauthorizedException)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to root_path
    assert_equal "Dataset files endpoint requires authorization. Dataverse: https://#{@new_id} persistentId: random_id page: 1", flash[:alert]
  end

  test "should display the dataset view with the file" do
    dataset = DataverseDatasetVersionResponse.new(dataset_valid_json)
    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = DataverseDatasetFilesResponse.new(files_valid_json)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/GCN7US")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 2
  end

  test "should display the dataset incomplete with no data" do
    dataset = DataverseDatasetVersionResponse.new(dataset_incomplete_json_no_data)
    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = DataverseDatasetFilesResponse.new(files_incomplete_no_data_json)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/LLIZ6Q")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 0
  end

  test "should display the dataset incomplete with no data file" do
    dataset = DataverseDatasetVersionResponse.new(dataset_incomplete_json_no_data)
    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = DataverseDatasetFilesResponse.new(files_incomplete_no_data_file_json)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/LLIZ6Q")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 2
  end

  test "should redirect if project fails to save" do
    dataset = DataverseDatasetVersionResponse.new(dataset_valid_json)
    files_page = DataverseDatasetFilesResponse.new(files_valid_json)

    project = Project.new
    project.stubs(:save).returns(false)
    project.errors.add(:base, "Project save failed")

    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    DataverseProjectService.any_instance.stubs(:initialize_project).returns(project)

    post download_dataverse_dataset_files_url, params: {
      file_ids: ["123"],
      project_id: nil,
      dataverse_url: "https://example.dataverse.org",
      persistent_id: "doi:10.5072/FK2/GCN7US",
      page: 1
    }

    assert_redirected_to root_path
    assert_equal "Error generating project: Project save failed", flash[:alert]
  end

  test "should redirect if any download file is invalid" do
    dataset = DataverseDatasetVersionResponse.new(dataset_valid_json)
    files_page = DataverseDatasetFilesResponse.new(files_valid_json)

    project = Project.new(name: "Test Project")
    project.stubs(:save).returns(true)

    invalid_file = DownloadFile.new(filename: "bad_file.txt")
    invalid_file.stubs(:valid?).returns(false)
    invalid_file.errors.add(:base, "Invalid file")
    valid_file = DownloadFile.new(filename: "good_file.txt")
    valid_file.stubs(:valid?).returns(true)

    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    DataverseProjectService.any_instance.stubs(:initialize_project).returns(project)
    DataverseProjectService.any_instance.stubs(:initialize_download_files).returns([valid_file, invalid_file])

    post download_dataverse_dataset_files_url, params: {
      file_ids: ["1", "2"],
      project_id: nil,
      dataverse_url: "https://example.dataverse.org",
      persistent_id: "doi:10.5072/FK2/GCN7US",
      page: 1
    }

    assert_redirected_to root_path
    assert_match "Invalid file in selection", flash[:alert]
    assert_match "bad_file.txt", flash[:alert]
  end

  test "should redirect if download file save fails" do
    dataset = DataverseDatasetVersionResponse.new(dataset_valid_json)
    files_page = DataverseDatasetFilesResponse.new(files_valid_json)

    project = Project.new(name: "Test Project")
    project.stubs(:save).returns(true)

    valid_file = DownloadFile.new(filename: "file.txt")
    valid_file.stubs(:valid?).returns(true)
    valid_file.stubs(:save).returns(false)

    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    DataverseProjectService.any_instance.stubs(:initialize_project).returns(project)
    DataverseProjectService.any_instance.stubs(:initialize_download_files).returns([valid_file])

    post download_dataverse_dataset_files_url, params: {
      file_ids: ["1"],
      project_id: nil,
      dataverse_url: "https://example.dataverse.org",
      persistent_id: "doi:10.5072/FK2/GCN7US",
      page: 1
    }

    assert_redirected_to root_path
    assert_equal "Error generating the download file", flash[:alert]
  end

  test "should redirect with notice if download files are saved successfully" do
    dataset = DataverseDatasetVersionResponse.new(dataset_valid_json)
    files_page = DataverseDatasetFilesResponse.new(files_valid_json)

    project = Project.new(name: "Test Project")
    project.stubs(:id).returns(1)
    project.stubs(:save).returns(true)

    file1 = DownloadFile.new(filename: "file1.txt")
    file1.stubs(:valid?).returns(true)
    file1.stubs(:save).returns(true)

    file2 = DownloadFile.new(filename: "file2.txt")
    file2.stubs(:valid?).returns(true)
    file2.stubs(:save).returns(true)

    DataverseDatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    DataverseDatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    DataverseProjectService.any_instance.stubs(:initialize_project).returns(project)
    DataverseProjectService.any_instance.stubs(:initialize_download_files).returns([file1, file2])

    post download_dataverse_dataset_files_url, params: {
      file_ids: ["1", "2"],
      project_id: nil,
      dataverse_url: "https://example.dataverse.org",
      persistent_id: "doi:10.5072/FK2/GCN7US",
      page: 1
    }

    assert_redirected_to root_path
    assert_equal "Files added to project: Test Project", flash[:notice]
  end

end
