class GitCloneJob < ApplicationJob
  queue_as :default

  def perform(environment)
    environment.execute_git_clone_job
  end

  rescue_from(Exception) do |e|
    logger.error(e)
    logger.error(e.backtrace.join("\n"))
  end

end
