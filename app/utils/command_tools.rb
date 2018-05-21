module CommandTools
  extend self

  def unlock_keychain_cmd
    "security unlock-keychain -p #{ENV['SYSTEM_PASSWORD']} ~/Library/Keychains/login.keychain"
  end

  # Run deliver command, and write output to log
  #
  # @param  [String] dest_dir
  # @return [String] cmd
  def run_deliver_command(dest_dir, cmd, log_file)
    cmds = []
    cmds << CommandTools.unlock_keychain_cmd
    cmds << cmd
    result = true
    output_string = ''
    Rails.logger.debug(dest_dir)
    Rails.logger.debug(cmds)
    File.truncate(log_file, 0) if File.exist?(log_file)
    begin
      Dir.chdir(dest_dir) do
        Open3.popen3(cmds.join(';')) {|stdin, stdout, stderr, wait_thr|
          while (line = stdout.gets) do
            file = File.open(log_file, 'a')
            file.write(line)
            output_string << line
            file.close
          end
          stdin.close
          exit_status = wait_thr.value
          result = (exit_status.success? and not report_contains_failure?(dest_dir))
        }
      end
    rescue => e
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace.join('\n'))
      result = false
    ensure
      result
    end
  end

  def self.run_command(cmd, log_file='')
    begin
      Rails.logger.debug(cmd)
      Open3.popen3(cmd) {|stdin, stdout, stderr, wait_thr|
        while (line = stdout.gets) do
          Rails.logger.debug(line)
          if File.exist?(log_file)
            file = File.open(log_file, 'a')
            file.write(line)
            file.close
          end
        end
        stdin.close
      }
    rescue => e
      Rails.logger.error(e.message)
      return false
    end
  end

  def report_contains_failure?(dest_dir)
    doc = Nokogiri::XML(File.open(File.join(dest_dir, 'fastlane', 'report.xml')))
    doc.search('//failure').size > 0
  end

end