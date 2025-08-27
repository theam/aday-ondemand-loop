require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)

    @project = Project.new(name: "test_project")
    @project.save

    Event.new(project_id: @project.id, type: EventType::DOWNLOAD_FILE_CREATED,
              metadata: { "download_file_id" => "file1" }).save
    Event.new(project_id: @project.id, type: EventType::PROJECT_UPDATED,
              metadata: { "note" => "updated" }).save
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should return all events" do
    get events_project_url(@project), headers: { "Accept" => "application/json" }

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 2, json.length
  end

  test "should filter events by type" do
    get events_project_url(@project, type: EventType::DOWNLOAD_FILE_CREATED.to_s),
        headers: { "Accept" => "application/json" }

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 1, json.length
    assert_equal "download_file_created", json.first["type"]
  end

  test "should filter events by metadata" do
    get events_project_url(@project, download_file_id: "file1"),
        headers: { "Accept" => "application/json" }

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 1, json.length
    assert_equal "file1", json.first["metadata"]["download_file_id"]
  end

  test "should return not found for missing project" do
    get events_project_url(id: "missing"), headers: { "Accept" => "application/json" }
    assert_response :not_found
  end

  test "should render events table in html with descending order" do
    Event.new(project_id: @project.id, type: EventType::PROJECT_CREATED,
              creation_date: DateTime.new(2023,1,1)).save
    Event.new(project_id: @project.id, type: EventType::PROJECT_UPDATED,
              creation_date: DateTime.new(2023,2,1)).save

    get events_project_url(@project), headers: { "Accept" => "text/html" }

    assert_response :success
    assert_includes @response.body, '<table'
    assert_match(/project_updated.*project_created/m, @response.body)
  end
end
