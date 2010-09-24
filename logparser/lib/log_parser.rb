
require 'apachelogregex'
require File.expand_path('../starling_queue', __FILE__)

class AccessLogReader

  def initialize(access_log_path, log_format)
    @access_log_stream = IO.new(IO.sysopen(access_log_path))
    @log_parser = ApacheLogRegex.new(log_format)
    @queue = StarlingQueue.new("hits_queue", "localhost:22123" )

    setup_signal_traps
  end

  def setup_signal_trap
    trap("INT") do
      puts "\nTerminating…"
      exit
    end

    trap("USR1") do
      puts @queue.length
    end
  end

  def read
    line = @access_log_stream.gets
    if line && line.match(/^.*$/)
      line_as_hash = @log_parser.parse!(line)
      @queue.push(line)
    end
  end
end



