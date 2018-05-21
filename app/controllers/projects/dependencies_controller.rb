class Projects::DependenciesController < Projects::ApplicationController

  # GET /projects/:project_id/dependencies
  def index
    @dependencies = @project.dependencies.paginate(page: params[:page] || 1)
    json_success(@dependencies)
  end

end
