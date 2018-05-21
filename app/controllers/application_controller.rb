class ApplicationController < ActionController::API

  include ActionController::Cookies
  include Response
  include ExceptionHandler

  before_action :authenticate, except: [:index]
  before_action :default_platform

  def index
    json_success({version: ENV['JAGUAR_VERSION']})
  end

  def authenticate
    if http_auth_header
      return
    end
    unless signed_in?
      unauthorized!
    end
  end

  def signed_in?
    current_user.present? && current_user.id.present?
  end

  def current_user
    user_id = cookies.encrypted[:user_id]
    session[:user_id] = user_id if user_id.present?
    @current_user ||= User.where(id: session[:user_id]).first
  end

  def current_platform
    if session[:platform].present?
      platform = session[:platform]
    else
      platform = 'ios'
    end
    platform
  end

  def current_platform_ios?
    current_platform == Project.platforms[:ios]
  end

  def current_platform_android?
    current_platform == Project.platforms[:android]
  end

  def default_platform
    platform = cookies.encrypted[:platform]
    if platform
      session[:platform] = platform
    else
      session[:platform] ||= "ios"
      cookies.encrypted[:platform] = {
          value: session[:platform],
          expires: 1.year.from_now,
      }
    end
  end

  def http_auth_header
    request.headers['Authorization'] == "Bearer #{ENV['JAGUAR_API_KEY']}"
  end

end
