# frozen_string_literal: true
require 'test_helper'
require 'ostruct'

class Download::DownloadServiceTest < ActiveSupport::TestCase

  def setup
    ConnectorClassDispatcher.stubs(:download_processor).returns(ConnectorDownloadProcessorMock.new)
  end

  test 'Only one download service should run at any given time' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      # THIS CONNECTOR WILL BLOCK ON CALLING download
      connector = ConnectorDownloadProcessorMock.new
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      file = stub({
        update: nil,
        save: nil,
        project_id: 'p1',
        id: 'f1',
        filename: 'file.txt'
      })
      files_provider = DownloadFilesProviderMock.new([file])

      main = download_service_thread(files_provider)
      sleep(0.1) # Allow t1 time to start and block
      # SHOULD CREATE LOCK FILE
      File.exist?(File.join(dir, 'download.lock'))

      # START OTHER
      other = download_service_thread(files_provider)

      # OTHER SHOULD FINISH IMMEDIATELY
      other.join
      refute other.alive?

      assert main.alive?, "Main DownloadService should still be blocked"
      # ONLY ONE FILE TO PROCESS => MAIN SHOULD TERMINATE AFTER COMPLETING THE PROCESSING
      connector.unblock
      main.join

      # ALL GOOD
      assert true
    end
  end

  test 'Should update the file status to downloading and success when success' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock("connector")
      connector.expects(:download).once.returns(OpenStruct.new({status: FileStatus::SUCCESS}))
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      now_time = file_now
      file = mock("download_file")
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::DOWNLOADING).once
      file.expects(:update).with(end_date: now_time, status: FileStatus::SUCCESS).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.stubs(:now).returns(now_time)
      target.expects(:log_event).with(project_id: 'p1', entity_type: 'download_file', entity_id: 'f1', message: 'events.download_file.started', metadata: { 'filename' => 'file.txt' })
      target.expects(:log_event).with(project_id: 'p1', entity_type: 'download_file', entity_id: 'f1', message: 'events.download_file.finished', metadata: { 'filename' => 'file.txt' })

      target.start
    end
  end

  test 'Should update the file status to downloading and error when error' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock('connector')
      connector.expects(:download).once.raises(StandardError, 'An error occurred')
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      now_time = file_now
      file = mock('download_file')
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::DOWNLOADING).once
      file.expects(:update).with(end_date: now_time, status: FileStatus::ERROR).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.stubs(:now).returns(now_time)
      target.expects(:log_event).with(project_id: 'p1', entity_type: 'download_file', entity_id: 'f1', message: 'events.download_file.started', metadata: { 'filename' => 'file.txt' })
      target.expects(:log_event).with(project_id: 'p1', entity_type: 'download_file', entity_id: 'f1', message: 'events.download_file.error', metadata: { 'filename' => 'file.txt', 'error' => 'An error occurred' })
      target.start
    end
  end

  test 'logs cancelled event when download processor returns cancelled status' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock('connector')
      connector.expects(:download).once.returns(OpenStruct.new({status: FileStatus::CANCELLED}))
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      now_time = file_now
      file = mock('download_file')
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::DOWNLOADING).once
      file.expects(:update).with(end_date: now_time, status: FileStatus::CANCELLED).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.stubs(:now).returns(now_time)
      target.expects(:log_event).with(project_id: 'p1', entity_type: 'download_file', entity_id: 'f1', message: 'events.download_file.started', metadata: { 'filename' => 'file.txt' })
      target.expects(:log_event).with(project_id: 'p1', entity_type: 'download_file', entity_id: 'f1', message: 'events.download_file.cancelled', metadata: { 'filename' => 'file.txt' })
      target.start
    end
  end

  test 'logs event when download processor returns error status' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock('connector')
      connector.expects(:download).once.returns(OpenStruct.new({status: FileStatus::ERROR, message: 'failed'}))
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      now_time = file_now
      file = mock('download_file')
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::DOWNLOADING).once
      file.expects(:update).with(end_date: now_time, status: FileStatus::ERROR).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.stubs(:now).returns(now_time)
      target.expects(:log_event).with(project_id: 'p1', entity_type: 'download_file', entity_id: 'f1', message: 'events.download_file.started', metadata: { 'filename' => 'file.txt' })
      target.expects(:log_event).with(project_id: 'p1', entity_type: 'download_file', entity_id: 'f1', message: 'events.download_file.error', metadata: { 'filename' => 'file.txt', 'message' => 'failed' })
      target.start
    end
  end


  private

  def download_service_thread(files_provider)
    Thread.new do
      target = Download::DownloadService.new(files_provider)
      target.start
    end
  end

  class ConnectorDownloadProcessorMock
    def initialize
      @queue = Queue.new # Used to control when the download unblocks
    end

    def download
      @queue.pop # Blocks until something is pushed into the queue
      OpenStruct.new({status: FileStatus::SUCCESS, message: 'OK'})
    end

    def unblock
      @queue.push(nil) # Unblocks any thread waiting on download
    end
  end
end
