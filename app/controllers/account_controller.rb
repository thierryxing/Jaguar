class AccountController < ApplicationController

  skip_before_action :authenticate, :default_platform

  # Post /account/login
  def login
    email = params[:email].to_s
    password = params[:password].to_s
    if email.empty? or password.empty?
      json_error('Invalid email or password')
    else
      begin
        gitlab_user = Gitlab.session(email, password).to_hash
        user = User.sync_with_gitlab_account(gitlab_user)
        create_session_and_cookie(user)
        user.platform = current_platform
        json_success(user)
      rescue Exception => e
        json_error(e.message)
      end
    end
  end

  def logout
    begin
      destroy_session_and_cookie
      json_success
    rescue Exception => e
      json_error(e.message)
    end
  end


  private

  def create_session_and_cookie(user)
    session[:user_id] = user.id
    cookies.encrypted[:user_id] = {
        value: user.id,
        expires: 1.year.from_now,
    }
  end

  def destroy_session_and_cookie
    session[:user_id] = nil
    cookies.clear[:user_id]
  end

end
