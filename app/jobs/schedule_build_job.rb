class ScheduleBuildJob < ApplicationJob
  queue_as :default

  def perform(env_id)
    environment = Environment.find(env_id)
    if environment.has_executing_builds?
      return
    end
    release_notes = environment.build_release_notes
    if release_notes.size > 0
      release_notes.each {|note| note.save}
      Build.init_and_do_build(environment)
    end
  end

  rescue_from(Exception) do |e|
    logger.error(e)
    logger.error(e.backtrace.join("\n"))
  end

end
