require "test_helper"
require "tmpdir"

class Observability::LocalLogTest < ActiveSupport::TestCase
  test "rotation bounds generations and preserves JSONL in a private directory" do
    Dir.mktmpdir do |directory|
      logger = Observability::LocalLog.build(directory: directory, environment: "test", files: 3, max_size: 100)
      30.times { |index| logger.info({ event: "probe", index: index }.to_json) }
      logger.close
      files = Dir[File.join(directory, "test.jsonl*")]
      assert_equal 3, files.size
      assert_equal 0o700, File.stat(directory).mode & 0o777
      events = files.flat_map { |path| File.readlines(path).map { |line| JSON.parse(line) } }
      assert events.all? { |event| event.fetch("event") == "probe" }
      assert_equal 29, JSON.parse(File.readlines(File.join(directory, "test.jsonl")).last).fetch("index")
    end
  end
end
