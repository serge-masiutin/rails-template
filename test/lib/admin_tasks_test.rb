require "test_helper"
require "rake"

class AdminTasksTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("admin:grant")
    @previous_email = ENV["EMAIL"]
    ENV["EMAIL"] = users(:one).email_address.upcase
    %w[admin:grant admin:revoke].each { |name| Rake::Task[name].reenable }
  end

  teardown do
    ENV["EMAIL"] = @previous_email
  end

  test "CLI grants and revokes the role for an existing user" do
    assert_output("Administrator access granted\n") { Rake::Task["admin:grant"].invoke }
    assert users(:one).reload.admin?
    assert_output("Administrator access revoked\n") { Rake::Task["admin:revoke"].invoke }
    refute users(:one).reload.admin?
  end

  test "CLI does not create a user for an unknown email" do
    ENV["EMAIL"] = "absent@example.com"
    assert_no_difference "User.count" do
      assert_raises(ActiveRecord::RecordNotFound) { Rake::Task["admin:grant"].invoke }
    end
  end
end
