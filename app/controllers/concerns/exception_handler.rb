module ExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do

    rescue_from ActiveRecord::RecordNotFound do |e|
      logger_exception(e)
      not_found!
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      logger_exception(e)
      record_invalid!
    end

  end

  def logger_exception(e)
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end

end
