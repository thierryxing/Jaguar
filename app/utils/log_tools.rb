class LogTools

  attr_accessor :log_file
  LOG_READ_LIMIT = 20

  def initialize(log_file)
    @log_file = log_file
  end

  # Fetch lines from log and return back to web.
  #
  # @param  [Boolean] all If need read all text log
  # @param  [Integer] offset The line number read log from
  # @return [String] log content
  def fetch_log_content(all=false, offset=0)
    content = ""
    begin
      file = File.open(@log_file, 'r')
      index = 0
      file.each_line do |line|
        if file.lineno > offset
          if all or index < LOG_READ_LIMIT
            content << line
          end
          index = index + 1
        end
      end
      file.close
    rescue => e
      raise
    end
    content
  end

  def log_line_count
    file = File.open(@log_file, 'r')
    count = file.lines.count
    file.close
    count
  end

end