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

class BuglyService < Service

  prop_accessor :app_id, :app_key, :mapping_file

  validates :app_id, presence: true, if: :activated?
  validates :app_key, presence: true, if: :activated?

  def service_type
    Service.service_types[:publish]
  end

  def title
    'Bugly'
  end

  def description
    'Bugly内测分发平台-符号表管理'
  end

  def help
    '腾讯Bugly，为移动开发者提供专业的异常上报，运营统计和内测分发解决方案，
     帮助开发者快速发现并解决异常，同时掌握产品运营动态，及时跟进用户反馈。'
  end

  def to_param
    'bugly'
  end

  def fields
    [
        {type: 'text', name: 'app_id', title: 'App ID', placeholder: ''},
        {type: 'text', name: 'app_key', title: 'App Key', placeholder: ''}
    ]
  end

  def execute(build)
    environment = build.environment
    project = build.project
    if project.android_app?
      symbol_type = 1
      file_name = 'mapping.txt'
      symbol_file = File.join(environment.mapping_dir, file_name)
    else
      symbol_type = 2
      file_name = 'app.dSYM.zip'
      symbol_file = File.join(build.build_dir, "#{build.build_name}.#{file_name}")
    end
    client = BuglyApiClient.new(app_id, app_key, symbol_type, project.identifier, environment.current_version, "", file_name, symbol_file)
    client.upload
  end

end

class BuglyApiClient

  UPLOAD_HOST = "https://api.bugly.qq.com/openapi/file/upload/symbol"
  API_VERSION = "1"

  attr_accessor :app_id, :app_key, :symbol_type, :bundle_id, :product_version, :channel, :file_name, :file

  def initialize(app_id, app_key, symbol_type, bundle_id, product_version, channel, file_name, file)
    @app_id = app_id
    @app_key = app_key
    @symbol_type = symbol_type
    @bundle_id = bundle_id
    @product_version = product_version
    @channel = channel
    @file_name = file_name
    @file = file
  end

  def command
    curl = %Q(curl -k "#{UPLOAD_HOST}?app_key=#{@app_key}&app_id=#{@app_id}")
    cmds = []
    cmds << %Q( --form "api_version=#{API_VERSION}")
    cmds << %Q("app_id=#{@app_id}")
    cmds << %Q("app_key=#{@app_key}")
    cmds << %Q("symbolType=#{@symbol_type}")
    cmds << %Q("bundleId=#{@bundle_id}")
    cmds << %Q("productVersion=#{@product_version}")
    cmds << %Q("channel=#{@channel}")
    cmds << %Q("fileName=#{@file_name}")
    cmds << %Q("file=@#{@file}")
    curl << cmds.join(' --form ')
    curl << ' --verbose'
    puts curl
    curl
  end

  def upload
    CommandTools.run_command(command)
  end

end
