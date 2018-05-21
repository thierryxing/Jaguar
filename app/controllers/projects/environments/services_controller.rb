module Projects
  module Environments
    class ServicesController < Environments::ApplicationController

      include ServiceParams

      before_action :service, only: [:update]

      def index
        services = @environment.find_or_initialize_services
        json_success(services)
      end

      def update
        if @service.update_attributes(service_params[:service])
          json_success(@service)
        else
          json_error(@service.error_messages)
        end
      end

      private

      def service
        @service ||= @environment.find_or_initialize_service(params[:id])
      end

    end
  end
end
