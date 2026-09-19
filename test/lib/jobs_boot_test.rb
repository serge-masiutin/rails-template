require "test_helper"
require "open3"
require "tempfile"

class JobsBootTest < ActiveSupport::TestCase
  test "worker preserves models and callbacks across a development reload attempt" do
    Tempfile.create([ "worker-boot-probe", ".rb" ]) do |probe|
      probe.write(<<~'RUBY')
        at_exit do
          next if $!

          process = SolidQueue::Process.allocate
          callback = Operations::QueueUpdates
          Rails.application.reloader.reload!
          ActionCable.server.config.cable = { "adapter" => "test" }
          callback.after_commit(nil)
          puts "WORKER_BOOT:#{JSON.generate(
            reloading: Rails.application.config.enable_reloading,
            same_model: process.is_a?(SolidQueue::Process),
            broadcasts: ActionCable.server.pubsub.broadcasts(Operations::Updates::STREAM).size
          )}"
        end
      RUBY
      probe.flush
      environment = {
        "RAILS_ENV" => "development",
        "ANYCABLE_SECRET" => "worker-boot-test-" * 4,
        "IMGPROXY_KEY" => "1" * 64,
        "IMGPROXY_SALT" => "2" * 64
      }
      output, errors, status = Open3.capture3(environment,
        RbConfig.ruby, "-r", probe.path, "bin/jobs", "check", chdir: Rails.root)
      assert status.success?, errors
      report = JSON.parse(output.lines.find { |line| line.start_with?("WORKER_BOOT:") }.delete_prefix("WORKER_BOOT:"))
      assert_equal({ "reloading" => false, "same_model" => true, "broadcasts" => 1 }, report)
    end
  end
end
