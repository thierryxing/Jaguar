class ProjectsController < ApplicationController

  before_action :get_project, only: [:show, :destroy, :update, :sync_gitlab]

  # GET /projects
  # @param [String] type The type of projects.
  # @param [String] platform The platform of projects.
  def index
    type = params[:type] || 'app'
    platform = params[:platform] || current_platform
    projects = Project.where(type: type.capitalize, platform: platform).paginate(page: params[:page] || 1)
    json_success(projects)
  end

  # GET /projects/:id
  def show
    json_success(@project)
  end

  # DELETE /projects/:id
  def destroy
    begin
      @project.destroy
      json_success
    rescue Exception => e
      json_error(e.message)
    end
  end

  # PUT /projects/:id
  def update
    begin
      @project.update!(project_params)
      json_success(@project)
    rescue Exception => e
      json_error(e.message)
    end
  end

  # GET /projects/:id/sync_gitlab
  def sync_gitlab
    if @project.sync_gitlab_project
      json_success(@project)
    else
      json_success(@project.error_messages)
    end
  end

  # POST /projects
  def create
    project = Project.new(project_params)
    project.platform = Project.platforms[session[:platform].downcase]
    if project.sync_gitlab_project
      json_success(project)
    else
      json_error(project.error_messages)
    end
  end

  def get_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:type, :identifier, :title, :git_repo_url).tap do |wl|
      wl[:guardian] = User.find(params[:project][:guardian][:id])
    end
  end

end
