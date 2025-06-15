# frozen_string_literal: true
require "test_helper"

class DataverseDownloadConnectorStatusTest < ActiveSupport::TestCase

  def setup
    @default_metadata = {
      id: '12345',
      download_location: fixture_path('/dataverse/download_connector_status/not_found.txt'),
      temp_location: fixture_path('/dataverse/download_connector_status/not_found.txt.part'),
    }
    @file = DownloadFile.new
    @file.type = ConnectorType::DATAVERSE
    @file.status = FileStatus::PENDING
    @file.metadata = @default_metadata
  end

  test "should return 0 for missing files" do
    @file.status = FileStatus::DOWNLOADING
    @file.size = 200

    target = DataverseDownloadConnectorStatus.new(@file)
    assert_equal 0, target.download_progress
  end

  test "should return 0 for pending files" do
    file_location = fixture_path('/dataverse/download_connector_status/100bytes_file.txt')
    @default_metadata[:temp_location] = file_location
    assert File.exist?(file_location)

    @file.status = FileStatus::PENDING
    @file.metadata = @default_metadata

    target = DataverseDownloadConnectorStatus.new(@file)
    assert_equal 0, target.download_progress
  end

  test "should return 100 if the destination file already created" do
    file_location = fixture_path('/dataverse/download_connector_status/100bytes_file.txt')
    @default_metadata[:download_location] = file_location
    @default_metadata[:temp_location] = file_location
    assert File.exist?(file_location)

    @file.status = FileStatus::DOWNLOADING
    @file.size = 200
    @file.metadata = @default_metadata

    target = DataverseDownloadConnectorStatus.new(@file)
    assert_equal 100, target.download_progress
  end

  test "should return 100 for completed files" do
    file_location = fixture_path('/dataverse/download_connector_status/100bytes_file.txt')
    @default_metadata[:temp_location] = file_location
    assert File.exist?(file_location)

    @file.status = FileStatus::SUCCESS
    @file.size = 200
    @file.metadata = @default_metadata

    target = DataverseDownloadConnectorStatus.new(@file)
    assert_equal 100, target.download_progress
  end

  test "should calculated percentage for downloading files" do
    file_location = fixture_path('/dataverse/download_connector_status/100bytes_file.txt')
    @default_metadata[:temp_location] = file_location
    assert File.exist?(file_location)

    @file.status = FileStatus::DOWNLOADING
    @file.size = 200
    @file.metadata = @default_metadata

    target = DataverseDownloadConnectorStatus.new(@file)
    assert_equal 50, target.download_progress
  end
end
