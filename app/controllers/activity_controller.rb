class ActivityController < ApplicationController

  # GET /activity/executing_builds
  def executing_builds
    builds = Build.where(status: Build.statuses[:processing]).paginate(page: params[:page] || 1)
    json_success(builds)
  end

end
