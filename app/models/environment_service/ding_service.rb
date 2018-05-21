# == Schema Information
#
# Table name: services
#
#  id         :integer          not null, primary key
#  type       :string
#  title      :string
#  project_id :integer
#  active     :boolean          default(FALSE), not null
#  properties :text
#  template   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'json'
class DingService < Service

  include Rails.application.routes.url_helpers

  prop_accessor :access_token
  validates :access_token, presence: true, if: :activated?

  def title
    '钉钉'
  end

  def description
    '钉钉'
  end

  def help
    '钉钉机器人通知'
  end

  def to_param
    'ding'
  end

  def fields
    [
        {type: 'text', name: 'access_token', title: 'Access Token', placeholder: ''},
    ]
  end

  def execute(build)
    BuildNotifier.send_result(build, access_token)
  end

end
