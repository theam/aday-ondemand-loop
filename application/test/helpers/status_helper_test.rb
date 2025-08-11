# frozen_string_literal: true
require 'test_helper'
require 'ostruct'

class StatusHelperTest < ActionView::TestCase
  include StatusHelper

  test 'cancel_button_disabled? should be true for these statuses' do
    [FileStatus::SUCCESS, FileStatus::ERROR, FileStatus::CANCELLED].each do |status|
      assert cancel_button_disabled?(status)
    end
  end

  test 'cancel_button_disabled should be false for these statuses' do
    [FileStatus::PENDING, FileStatus::DOWNLOADING, FileStatus::UPLOADING].each do |status|
      refute cancel_button_disabled?(status)
    end
  end

  test 'retry_button_visible? is true when status allows retry and restart is possible' do
    [FileStatus::CANCELLED, FileStatus::ERROR].each do |status|
      file = OpenStruct.new(status: status, connector_metadata: OpenStruct.new(restart_possible: true))
      assert retry_button_visible?(file)
    end
  end

  test 'retry_button_visible? is false when status does not allow retry or restart not possible' do
    file = OpenStruct.new(status: FileStatus::SUCCESS, connector_metadata: OpenStruct.new(restart_possible: true))
    refute retry_button_visible?(file)

    file = OpenStruct.new(status: FileStatus::CANCELLED, connector_metadata: OpenStruct.new(restart_possible: false))
    refute retry_button_visible?(file)
  end
end
