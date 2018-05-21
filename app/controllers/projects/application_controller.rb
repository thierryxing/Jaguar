class Projects::ApplicationController < ApplicationController

  before_action :get_project

  def get_project
    @project = Project.find(params[:project_id])
  end

  def project_params
    params.require(:projects).permit(:type, :identifier, :title, :git_repo_url).tap do |wl|
      wl[:guardian] = User.find(params[:projects][:guardian][:id])
    end
  end

end
