class Projects::HomeController < Projects::ApplicationController

  # GET /projects/home/:id/sync_gitlab
  def sync_gitlab
    if @project.sync_gitlab_project
      json_success(@project)
    else
      json_success(@project.error_messages)
    end
  end


end
