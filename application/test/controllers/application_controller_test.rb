require "test_helper"

class ApplicationControllerTest < ActionController::TestCase
  class DummyController < ApplicationController
    skip_before_action :load_user_settings

    def redirect_action
      redirect_to "/redirected"
    end

    def success_action
      render plain: Current.selected_project
    end

  end

  tests DummyController

  def setup
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get "redirect_action" => "application_controller_test/dummy#redirect_action"
      get "success_action" => "application_controller_test/dummy#success_action"
    end

    @request.env["action_dispatch.routes"] = @routes
    Current.selected_project = nil
    Current.settings = nil
  end

  test "sets flash redirect_params on redirect" do
    get :redirect_action, params: { selected_project: "42", unsafe: "nope" }
    assert_equal({ "selected_project" => "42" }, flash[:redirect_params])
  end

  test "does not set flash redirect_params without redirect" do
    get :success_action, params: { selected_project: "42" }
    assert_nil flash[:redirect_params]
  end

  test "sets Current attributes before action" do
    get :success_action, params: { selected_project: "99" }
    assert_equal "99", @response.body
  end

  test "uses flash redirect_params when params missing" do
    get :success_action, flash: { redirect_params: { "selected_project" => "55" } }
    assert_equal "55", @response.body
  end

end
