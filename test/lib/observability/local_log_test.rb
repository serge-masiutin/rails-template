require "test_helper"
require "tmpdir"

class Observability::LocalLogTest < ActiveSupport::TestCase
  test "the log restricts an existing directory and writes JSONL without a header" do
    Dir.mktmpdir do |directory|
      File.chmod(0o755, directory)
      logger = Observability::LocalLog.build(directory: directory, environment: "test")
      logger.info({ event: "probe" }.to_json)
      logger.close
      assert_equal 0o700, File.stat(directory).mode & 0o777
      assert_equal({ "event" => "probe" }, JSON.parse(File.read(File.join(directory, "test.jsonl"))))
    end
  end
end
