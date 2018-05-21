class FastlaneTemplatesController < ApplicationController

  before_action :get_template

  def index
    platform = params[:platform] || current_platform
    templates = FastlaneTemplate.where(platform: platform).paginate(page: params[:page] || 1)
    json_success(templates)
  end

  def show
    json_success(@template)
  end

  # DELETE /admin/fastlane_templates/:id
  def destroy
    begin
      @template.destroy
      json_success
    rescue Exception => e
      json_error(e.message)
    end
  end

  def create
    template = FastlaneTemplate.new(template_params)
    if template.save
      json_success(template)
    else
      json_error("Create template failed:#{template.error_messages}")
    end
  end

  def update
    begin
      @template.update(template_params)
      json_success(@template)
    rescue Exception => e
      json_error(e.message)
    end
  end

  private

  def get_template
    if params[:id].present?
      @template = FastlaneTemplate.find(params[:id])
    end
  end

  def template_params
    params.require(:fastlane_template).permit(:name, :command, :platform)
  end

end