require "test_helper"

class ExploreControllerTest < ActionDispatch::IntegrationTest
  def stub_processor(action, result)
    processor = mock("ExploreProcessor")
    processor.stubs(:params_schema).returns(%i[connector_type server_domain object_type object_id query server_scheme server_port])
    processor.expects(action).with(kind_of(Hash)).returns(result)
    ConnectorClassDispatcher.stubs(:explore_connector_processor).returns(processor)
  end

  test "landing action renders template when processor succeeds" do
    stub_processor(:landing, ConnectorResult.new(template: "/sitemap/index", locals: {}, success: true))

    get explore_landing_url(connector_type: "zenodo")

    assert_response :success
  end

  test "landing action redirects with message when processor fails" do
    stub_processor(:landing, ConnectorResult.new(message: { alert: "error" }, success: false))

    get explore_landing_url(connector_type: "zenodo")

    assert_redirected_to root_path
    assert_equal "error", flash[:alert]
  end

  test "redirects when repo url is invalid" do
    get "/explore/zenodo/%20/records/1"

    assert_redirected_to root_path
    assert_equal I18n.t("explore.show.message_invalid_repo_url", repo_url: ""), flash[:alert]
  end

  test "show action renders template when processor succeeds" do
    stub_processor(:show, ConnectorResult.new(template: "/sitemap/index", locals: {}, success: true))

    get explore_url(
      connector_type: "zenodo",
      server_domain: "example.org",
      object_type: "records",
      object_id: "1"
    )

    assert_response :success
  end

  test "show action redirects with message when processor fails" do
    stub_processor(:show, ConnectorResult.new(message: { alert: "error" }, success: false))

    get explore_url(
      connector_type: "zenodo",
      server_domain: "example.org",
      object_type: "records",
      object_id: "1"
    )

    assert_redirected_to root_path
    assert_equal "error", flash[:alert]
  end

  test "create action redirects with message from processor" do
    stub_processor(:create, ConnectorResult.new(message: { notice: "ok" }, success: true))

    post explore_url(
      connector_type: "zenodo",
      server_domain: "example.org",
      object_type: "records",
      object_id: "1"
    )

    assert_redirected_to root_path
    assert_equal "ok", flash[:notice]
  end
end
