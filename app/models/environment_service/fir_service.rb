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

class FirService < Service
  prop_accessor :api_token, :download_url
  validates :api_token, presence: true, if: :activated?

  def service_type
    Service.service_types[:publish]
  end

  def title
    'Fir'
  end

  def description
    'Fir - 服务移动开发者，让开发测试更高效'
  end

  def help
    'You can create a Personal Access Token here: https://fir.im/support'
  end

  def to_param
    'fir'
  end

  def fields
    [
        {
            type: 'text',
            name: 'api_token',
            title: 'API Token',
            placeholder: 'API Token at fir.im'
        },
        {
            type: 'text',
            name: 'download_url',
            title: '短链接',
            placeholder: '下载页面短链接'
        }
    ]
  end

  def execute(build)
    json_file = build.get_build_log
    CommandTools.run_command("fir p #{build.build_file_path} -T #{api_token}", json_file)
  end

end
