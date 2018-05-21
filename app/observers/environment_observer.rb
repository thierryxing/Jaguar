class EnvironmentObserver < ActiveRecord::Observer

  def after_save(environment)
    update_or_create_dir_name(environment)
    update_cron(environment)
  end

  def after_destroy(environment)
    FileUtils.rm_r(environment.env_dir)
  end

  # Update dir name if environment's name changed or create environment dir if not exist
  def update_or_create_dir_name(environment)
    if environment.saved_change_to_name?
      if environment.name_before_last_save
        Dir.chdir(environment.project.project_dir) do
          File.rename(environment.name_before_last_save, environment.name)
        end
      else
        environment.env_dir
      end
    end
  end

  # Update dir name if environment's name changed
  def update_cron(environment)
    if environment.saved_change_to_cron?
      if environment.cron.present?
        environment.set_build_schedule
      else
        environment.remove_build_schedule
      end
    end
  end

end
