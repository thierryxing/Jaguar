# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  name          :string
#  username      :string
#  gitlab_id     :string
#  state         :string
#  avatar_url    :string
#  is_admin      :boolean
#  private_token :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class User < ApplicationRecord

  attr_accessor :platform
  has_many :projects, dependent: :destroy

  def self.sync_with_gitlab_account(gitlab_user)
    user = User.find_by_gitlab_id(gitlab_user['id'])
    unless user.present?
      user = User.new
    end
    user.avatar_url = gitlab_user['avatar_url']
    user.name = gitlab_user['name']
    user.username = gitlab_user['username']
    user.state = gitlab_user['state']
    user.is_admin = gitlab_user['is_admin']
    user.private_token = gitlab_user['private_token']
    user.gitlab_id = gitlab_user['id']
    user.save
    user
  end

  def project_names
    self.projects.map {|project| project.title}.join(', ')
  end

  def api_data
    {
        id: id,
        name: name,
        avatar_url: avatar_url,
        created_at: I18n.l(created_at),
        platform: platform
    }
  end

end
