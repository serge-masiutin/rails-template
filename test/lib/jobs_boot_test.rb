require "test_helper"
require "open3"
require "tempfile"

class JobsBootTest < ActiveSupport::TestCase
  test "worker preserves models and callbacks across a development reload attempt" do
    Tempfile.create([ "worker-boot-probe", ".rb" ]) do |probe|
      probe.write(<<~'RUBY')
        load "bin/jobs"
        process = SolidQueue::Process.allocate
        callback = Observability::QueueUpdates
        Rails.application.reloader.reload!
        ActionCable.server.config.cable = { "adapter" => "test" }
        callback.after_commit(nil)
        Realtime::OperationsUpdates.flush
        puts "WORKER_BOOT:#{JSON.generate(
          reloading: Rails.application.config.enable_reloading,
          same_model: process.is_a?(SolidQueue::Process),
          broadcasts: ActionCable.server.pubsub.broadcasts(Realtime::OperationsUpdates::STREAM).size
        )}"
      RUBY
      probe.flush
      environment = {
        "RAILS_ENV" => "development",
        "PGPORT" => "1",
        "ANYCABLE_SECRET" => "worker-boot-test-" * 4,
        "IMGPROXY_KEY" => "1" * 64,
        "IMGPROXY_SALT" => "2" * 64
      }
      # Boot and reload without starting the scheduler or accessing the development database.
      output, errors, status = Open3.capture3(environment,
        RbConfig.ruby, probe.path, "check", "--skip-recurring", chdir: Rails.root)
      assert status.success?, errors
      report = JSON.parse(output.lines.find { |line| line.start_with?("WORKER_BOOT:") }.delete_prefix("WORKER_BOOT:"))
      assert_equal({ "reloading" => false, "same_model" => true, "broadcasts" => 1 }, report)
    end
  end
end
