require 'test_helper'

class Zenodo::DownloadConnectorStatusTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @file = create_download_file(@project)
    @file.size = 100
    @file.status = FileStatus::DOWNLOADING
    @file.metadata = {temp_location: File.join(Dir.tmpdir, 'temp'), download_location: File.join(Dir.tmpdir, 'dest')}
    File.write(@file.metadata[:temp_location], 'a' * 50)
    @status = Zenodo::DownloadConnectorStatus.new(@file)
  end

  def teardown
    FileUtils.rm_f(@file.metadata[:temp_location])
    FileUtils.rm_f(@file.metadata[:download_location])
  end

  test 'calculates progress from temp file' do
    assert_equal 50, @status.download_progress
  end

  test 'returns 100 when destination exists' do
    FileUtils.touch(@file.metadata[:download_location])
    assert_equal 100, @status.download_progress
  end
end
