module Projects
  module Environments
    class FastlaneController < Environments::ApplicationController

      # GET /projects/:project_id/environments/:environment_id/fastlane
      def index
        unless @environment.git_dir_exist?
          json_error('You need to clone project first')
        end
        files = @environment.init_fastfiles
        json_success(files)
      end

      # PUT /projects/:project_id/environments/:environment_id/fastlane/update_fastfile
      def update_fastfile
        begin
          @environment.update_fastfile(params[:name], params[:content])
          json_success
        rescue => e
          json_error(e.message)
        end
      end

    end
  end
end
