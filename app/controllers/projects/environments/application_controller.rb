module Projects
  module Environments
    class ApplicationController < Projects::ApplicationController

      before_action :get_environment
      before_action :check_environment_building, only: [:build]
      before_action :check_environment_valid, only: [:git_branch, :git_clone, :fastlane, :update_fastfile]

      def get_environment
        @environment = Environment.find(params[:environment_id])
      end

      def check_environment_valid
        unless @environment.valid?
          json_error(@environment.errors)
        end
      end

      def check_environment_building
        if @environment.has_executing_builds?
          json_error('One building job executed in current environment, please wait')
        end
      end

    end
  end
end
