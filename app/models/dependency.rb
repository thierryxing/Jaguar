# == Schema Information
#
# Table name: dependencies
#
#  id          :integer          not null, primary key
#  name        :string
#  version     :string
#  project_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  is_internal :boolean          default(FALSE)
#

class Dependency < ApplicationRecord

  belongs_to :project

  def latest_version
    name = self.name
    if self.project.ios?
      depend_project = Project.where(title: name, platform: Project.platforms[self.project.platform]).first
    else
      depend_project = Project.where(identifier: name, platform: Project.platforms[self.project.platform]).first
    end
    if depend_project
      depend_project.current_version
    else
      ''
    end
  end

  def api_data
    {
        id: id,
        name: name,
        current_version: version,
        latest_version: latest_version,
        need_update: need_update
    }
  end

  def need_update
    VersionTools.new(version).matches?('<', latest_version)
  end

end
