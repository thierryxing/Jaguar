module Response

  module Status
    SUCCESS = 0
    FAILED = 1
  end

  def json_success(object={})
    begin
      if object.kind_of?(ActiveRecord::Relation) or object.kind_of?(WillPaginate::Collection) or object.kind_of?(Array)
        list = object.map {|o| o.respond_to?(:api_data) ? o.api_data : o}
        if object.respond_to?(:total_entries)
          data = {list: list, total: object.total_entries}
        else
          data = {list: list, total: object.size}
        end
      elsif object.kind_of?(ActiveRecord::Base) and object.respond_to?(:api_data)
        data = object.api_data
      else
        data = object
      end
    rescue Exception => e
      Rails.logger.error(e)
      Rails.logger.error(e.backtrace.join("\n"))
      data = object
    end
    json_response(data)
  end

  def json_error(message)
    json_response({}, Status::FAILED, message)
  end

  def json_response(object, status = Status::SUCCESS, message = "", http_status=:ok)
    json_wrapper = {
        status: status,
        message: message,
        data: object
    }
    render json: json_wrapper, status: http_status
  end

  def forbidden!(reason = nil)
    message = ['403 Forbidden']
    message << " - #{reason}" if reason
    render_api_error!(message.join(' '), 403)
  end

  def bad_request!(attribute)
    message = ["400 (Bad request)"]
    message << "\"" + attribute.to_s + "\" not given"
    render_api_error!(message.join(' '), 400)
  end

  def not_found!(resource = nil)
    message = ["404"]
    message << resource if resource
    message << "Not Found"
    render_api_error!(message.join(' '), 404)
  end

  def unauthorized!
    render_api_error!('401 Unauthorized', 401)
  end

  def not_allowed!
    render_api_error!('405 Method Not Allowed', 405)
  end

  def conflict!(message = nil)
    render_api_error!(message || '409 Conflict', 409)
  end

  def file_to_large!
    render_api_error!('413 Request Entity Too Large', 413)
  end

  def not_modified!
    render_api_error!('304 Not Modified', 304)
  end

  def record_invalid!
    render_api_error!('500 Record Invalid', 500)
  end

  def server_exception!(e)
    render_api_error!(e.message, 500)
  end

  def render_validation_error!(model)
    if model.errors.any?
      render_api_error!(model.errors.messages || '400 Bad Request', 400)
    end
  end

  def render_api_error!(message, status)
    json_response({}, Status::FAILED, message, status)
  end

end