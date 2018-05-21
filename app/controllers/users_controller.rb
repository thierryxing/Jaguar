class UsersController < ApplicationController

  # GET /users
  def index
    @users = User.all.paginate(page: params[:page] || 1)
    json_success(@users)
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
    json_success(@user)
  end

  # GET /users/:id/set_platform/:platform
  def set_platform
    session[:platform] = params[:platform]
    cookies.encrypted[:platform] = {
        value: params[:platform],
        expires: 1.year.from_now,
    }
    json_success({platform: params[:platform]})
  end

end
