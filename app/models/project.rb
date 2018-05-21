# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  title          :string
#  desc           :string
#  icon           :string
#  git_repo_url   :string
#  created_at     :datetime
#  updated_at     :datetime
#  clone_status   :integer
#  git_project_id :integer
#  type           :string           default("0")
#  platform       :integer          default("ios")
#  admin_id       :integer
#  user_id        :integer
#  identifier     :string
#  cron           :string
#  name           :string
#

class Project < ApplicationRecord

  enum platform: %i( ios android )

  validates :title, presence: true
  validates_uniqueness_of :title, :scope => :platform
  validates :git_repo_url, presence: true, uniqueness: true

  belongs_to :guardian, class_name: 'User', foreign_key: :user_id
  accepts_nested_attributes_for :guardian

  has_many :environments
  has_many :builds, -> {order('created_at DESC')}, dependent: :destroy

  # Dependency
  has_many :dependencies, -> {order 'is_internal DESC'}, dependent: :destroy
  has_many :internal_dependencies, -> {where is_internal: true}, class_name: 'Dependency'
  has_many :external_dependencies, -> {where is_internal: false}, class_name: 'Dependency'

  def icon
    if self[:icon].present?
      "#{self[:icon]}?private_token=#{ENV['GITLAB_PRIVATE_TOKEN']}"
    else
      "#{ENV['QINIU_URL']}/jaguar-512.png"
    end
  end

  def app?
    self.type == 'App'
  end

  def lib?
    self.type == 'Lib'
  end

  def android_app?
    android? and app?
  end

  def ios_app?
    ios? and app?
  end

  def fetch_gitlab_project
    name = self.git_repo_url.split(':')[1].gsub('.git', '')
    Gitlab.project(CGI::escape(name)).to_hash
  rescue => e
    logger.debug e.message
    return nil
  end

  #
  def project_dir
    dir = File.join(Jaguar::JAGUAR_HOME, self.platform, self.title)
    FileTools.mkdir_if_not_exist(dir)
  end

  def app_files_dir
    dir = File.join(Jaguar::APP_FILES, self.platform, self.title)
    FileTools.mkdir_if_not_exist(dir)
  end

  def log_file_dir
    dir = File.join(Jaguar::DELIVER_LOG_DIR, self.platform, self.title)
    FileTools.mkdir_if_not_exist(dir)
  end

  def api_data
    {
        id: id,
        title: title,
        desc: desc,
        identifier: identifier,
        type: type,
        icon: icon,
        platform: platform,
        git_repo_url: git_repo_url,
        lasted_build_at: lasted_build_at,
        updated_at: I18n.l(updated_at),
        guardian: {
            id: self.guardian.id,
            name: self.guardian.name
        }
    }
  end

  def save_with_user(user_id)
    user = User.find(user_id)
    self.guardian = user
    self.save
  end

  def lasted_build_at
    if builds.count > 0
      builds.last.updated_at.to_s(:short)
    else
      ''
    end
  end

  def sync_gitlab_project
    gitlab_project = self.fetch_gitlab_project
    puts gitlab_project.inspect
    unless gitlab_project
      self.errors.add(:base, 'Git repository does not exists')
      return false
    end
    self.title = gitlab_project['name']
    self.git_project_id = gitlab_project['id']
    self.icon = gitlab_project['avatar_url']
    self.desc = gitlab_project['description'] || project.title
    self.git_repo_url = gitlab_project['ssh_url_to_repo']
    self.save
  end

end


