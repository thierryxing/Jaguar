class Projects::BuildsController < Projects::ApplicationController

  skip_before_action :authenticate, only: [:download]
  before_action :get_build

  # GET /projects/:project_id/builds
  # @param [String] status The specify status of builds.
  # @param [Integer] environment_id The specify environment ID of builds.
  def index
    condition = {}
    condition[:status] = params[:status] if params[:status].present?
    condition[:environment_id] = params[:environment_id] if params[:environment_id].present?
    condition[:project_id] = params[:project_id] if params[:project_id].present?
    builds = Build.where(condition).order('id desc').paginate(page: params[:page] || 1)
    json_success(builds)
  end

  # GET /projects/:project_id/builds/:id
  def show
    json_success(@build)
  end

  # DELETE /projects/:project_id/builds/:id
  def destroy
    begin
      @build.destroy
      json_success
    rescue Exception => e
      json_error(e.message)
    end
  end

  # GET /projects/:project_id/builds/:id/log
  def log
    begin
      offset = params[:offset].to_i
      should_poll = @build.processing?
      fetch_all_log = (offset == 0 or not @build.processing?)
      tools = LogTools.new(@build.get_build_log)
      log = tools.fetch_log_content(fetch_all_log, offset)
      json_success({log: FileTools.escape_ansi_to_html(log), should_poll: should_poll, offset: offset+log.lines.count})
    rescue Exception => e
      json_error(e.message)
    end
  end

  # GET /projects/:project_id/builds/:id/download
  def download
    send_file(@build.build_file_path)
  end

  # GET /projects/:project_id/builds/:id/mark_status?status=:status
  def mark_status
    if params[:status]
      @build.status = Build.statuses[params[:status]]
      @build.save
    end
    json_success
  end

  private

  def get_build
    if params[:id].present?
      @build = Build.find(params[:id])
    end
  end

end
