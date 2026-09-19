require "logger"
require "fileutils"

module Observability
  module LocalLog
    # Ruby Logger coordinates rotation across processes; the private directory protects every generation.
    def self.build(directory:, environment:, files: 5, max_size: 20 * 1024 * 1024)
      FileUtils.mkdir_p(directory)
      File.chmod(0o700, directory)
      Logger.new(File.join(directory, "#{environment}.jsonl"), files, max_size,
        skip_header: true, reraise_write_errors: [ IOError, SystemCallError ],
        formatter: ->(_severity, _time, _name, message) { "#{message}\n" })
    end
  end
end
