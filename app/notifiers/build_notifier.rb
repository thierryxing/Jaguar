class BuildNotifier < ApplicationNotifier

  def send_result(build, access_token)
    if access_token.present?
      @build = build
      title = "#{@build.project.title}-#{@build.project.platform.upcase} 第#{@build.id}次构建 #{@build.status}"
      dingtalk(access_token, title)
    end
  end

end