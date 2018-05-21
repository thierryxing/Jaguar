class BuildJob < ApplicationJob
  queue_as :default

  def perform(build)
    build.execute_build_job
  end

  rescue_from(Exception) do |e|
    logger.error(e)
    logger.error(e.backtrace.join("\n"))
  end

end
