module ServiceParams
  extend ActiveSupport::Concern

  ALLOWED_PARAMS = [
      :active,
      :service_type,
      :app_id,
      :app_key,
      :api_token,
      :access_token,
      :download_url
  ]

  # Parameters to ignore if no value is specified
  FILTER_BLANK_PARAMS = [:password]

  def service_params
    service_params = params.permit(:id, service: ALLOWED_PARAMS)

    if service_params[:service].is_a?(Hash)
      FILTER_BLANK_PARAMS.each do |param|
        service_params[:service].delete(param) if service_params[:service][param].blank?
      end
    end

    service_params
  end
end
