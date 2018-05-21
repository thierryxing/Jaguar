class DashboardController < ApplicationController

  def index
    builds_count = Build.all.count
    if builds_count > 0
      success_rate = "#{((Build.succeed.count.to_f/builds_count.to_f)*100).round}%"
      projects_count = Project.all.count
      user_count = User.all.count
      data = [
          {name: 'Builds', value: builds_count},
          {name: 'Success Rate', value: success_rate},
          {name: 'Projects', value: projects_count},
          {name: 'Members', value: user_count}
      ]
      json_success(data)
    else
      json_success
    end
  end

  def weekly_data
    result = []
    Project.platforms.each do |platform, index|
      platform_data = {platform: platform, data: [], days: []}
      (0..6).each do |number|
        date = Time.now-number.days
        day_in_week = date.strftime("%m-%d")
        day_start = date.beginning_of_day
        day_end = date.end_of_day
        count = Build.joins(:project).where('builds.created_at between ? and ? and projects.platform=?', day_start, day_end, index).count
        platform_data[:data] << count
        platform_data[:days] << day_in_week
      end
      platform_data[:data] = platform_data[:data].reverse
      platform_data[:days] = platform_data[:days].reverse
      result << platform_data
    end
    json_success(result)
  end

end
