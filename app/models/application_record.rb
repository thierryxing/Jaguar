class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Returns the +Errors+ string that holds all information about attribute
  def error_messages
    message = ""
    self.errors.each do |item, error|
      message = "#{item.to_s} #{error.to_s}"
    end
    message
  end

  def logger_exception(e)
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end

end
