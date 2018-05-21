class Projects::EnvironmentsController < Projects::ApplicationController

  before_action :get_environment

  # GET /projects/:project_id/environments
  def index
    @environments = @project.environments.paginate(page: params[:page] || 1)
    json_success(@environments)
  end

  # GET /projects/:project_id/environments/:id
  def show
    json_success(@environment)
  end

  # POST /projects/:project_id/environments
  def create
    environment = Environment.new(env_params)
    environment.project = @project
    if environment.save
      json_success(environment)
    else
      json_error("Create environment failed:#{environment.error_messages}")
    end
  end

  # PUT /projects/:project_id/environments/:id
  def update
    begin
      @environment.update(env_params)
      json_success(@environment)
    rescue Exception => e
      logger_exception(e)
      json_error(e.message)
    end
  end

  # DELETE /projects/:project_id/environments/:id
  def destroy
    begin
      @environment.destroy
      json_success
    rescue Exception => e
      json_error(e.message)
    end
  end

  # POST /projects/:project_id/environments/:id/clone
  def clone
    environment = Environment.new(@environment.dup.attributes.merge(env_params))
    environment.cron = ""
    if environment.save
      environment.cp_dir(@environment)
      json_success(environment)
    else
      json_error("Clone environment failed:#{environment.error_messages}")
    end
  end

  # GET /projects/:project_id/environments/:id/configs
  def configs
    json_success(@environment.configs)
  end

  # GET /projects/:project_id/environments/:id/build_info
  def build_info
    begin
      current_version = @environment.current_version
      version = @environment.next_version
      notes = @environment.build_release_notes.map {|note| "#{note.content}"}
      json_success({
                       notes: notes,
                       current_version: current_version,
                       version: version
                   })
    rescue => e
      json_error(e.message)
    end
  end

  # POST /projects/:project_id/environments/:id/build
  def build
    version = params[:version] || ''
    notes = params[:notes] || ''

    if @project.lib?
      if version.empty?
        json_error('Please specific the release version')
        return
      end

      if VersionTools.new(version).matches?('<', @environment.current_version)
        json_error("Version can not less or equal than current version:#{@environment.current_version}")
        return
      end
    end

    build = Build.init_and_do_build(@environment, current_user: current_user, version: version, notes: notes)
    json_success(build)
  end

  private

  def get_environment
    if params[:id].present?
      @environment = Environment.find(params[:id])
    end
  end

  def env_params
    params.require(:environment).permit(:name, :scheme, :main_module, :gradle_task, :cron, :git_branch, :clone_status).tap do |wl|
      wl[:fastlane_template] = FastlaneTemplate.find(params[:environment][:fastlane_template][:id])
    end
  end

end
