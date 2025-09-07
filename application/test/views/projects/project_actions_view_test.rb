# frozen_string_literal: true

require 'test_helper'

class ProjectActionsViewTest < ActionView::TestCase
  include ModelHelper

  test 'renders repository activity button' do
    project = create_project

    view.stubs(:active_project?).returns(false)

    html = render partial: 'projects/show/project_actions', locals: { project: project }

    expected_url = widgets_path('repository_activity', project_id: project.id)
    assert_includes html, expected_url
    assert_includes html, t('projects.show.project_actions.button_add_files_title')
  end
end
