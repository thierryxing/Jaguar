# == Schema Information
#
# Table name: environments
#
#  id                :integer          not null, primary key
#  git_branch        :string
#  scheme            :string
#  project_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  build_template    :integer
#  is_default        :boolean
#  main_module       :string
#  name              :string
#  clone_status      :integer          default("prepare")
#  ding_access_token :string
#

class Environment < ApplicationRecord

  include FastfileHandler
  include DirHandler
  include VersionHandler
  include ServiceHandler

  validates :name, presence: true
  validates_uniqueness_of :name, scope: :project_id
  validates_uniqueness_of :cron, if: -> env {env.cron.present?}
  validates :scheme, presence: true, if: -> env {env.project.app?}
  validates :main_module, presence: true, if: -> env {env.project.android_app?}

  belongs_to :project

  has_many :builds, -> {order(created_at: :desc)}, dependent: :destroy
  has_many :services, -> {order(created_at: :desc)}, dependent: :destroy
  has_many :active_publish_services, -> {where(active: 1, service_type: Service.service_types[:publish])}, class_name: 'Service', dependent: :destroy
  has_many :active_notification_services, -> {where(active: 1, service_type: Service.service_types[:notification])}, class_name: 'Service', dependent: :destroy
  has_many :executing_builds, -> {where(status: Build.statuses[:processing]).order(created_at: :desc)}, class_name: 'Build', dependent: :destroy
  belongs_to :fastlane_template

  scope :scheduled, -> {where("cron is not null and cron!=''")}

  enum clone_status: %i( prepare processing success failed )

  def execute_git_clone_job
    begin
      unless git_dir_exist?
        Git.clone(project.git_repo_url, project.title, path: env_dir)
      end
      self.clone_status = Environment.clone_statuses[:success]
    rescue => e
      logger.error(e.backtrace.join("\n"))
      self.clone_status = Environment.clone_statuses[:failed]
    ensure
      self.save
    end
  end

  def api_data
    {
        id: id,
        name: name,
        git_branch: git_branch,
        git_tag: git_tag,
        scheme: scheme,
        current_version: current_version,
        clone_status: clone_status,
        main_module: main_module,
        gradle_task: gradle_task,
        updated_at: I18n.l(updated_at),
        can_build: can_build?,
        ding_access_token: ding_access_token,
        cron: cron,
        fastlane_template: fastlane_template.api_data
    }
  end

  def configs
    [
        {
            id: "git_clone",
            name: "Git",
            desc: "Git clone the project to local",
            finished: git_clone_finished?
        },
        {
            id: "fastlane",
            name: "Fastlane",
            desc: "Initialize fastlane file of the environment",
            finished: fastlane_finished?
        },
        {
            id: "services",
            name: "Service",
            desc: "Config services of this environment",
            finished: services_finished?
        }
    ]
  end

  def build_release_notes
    release_notes = []
    unless git_branch.present?
      return release_notes
    end
    git = Git.open(git_dir)
    git.fetch
    logs = git.log.object("HEAD..origin/#{git_branch}")
    logs.each do |log|
      unless log.message.include?('Merge')
        note = ReleaseNote.new
        note.content = log.message
        release_notes << note
      end
    end
    release_notes
  end

  def services_finished?
    true
  end

  def git_clone_finished?
    git_dir_exist? and git_branch.present?
  end

  def fastlane_finished?
    git_clone_finished?
  end

  def can_build?
    fastlane_finished?
  end

  def has_executing_builds?
    executing_builds.count > 0
  end

  def set_build_schedule
    Sidekiq.set_schedule(schedule_name, {args: id, cron: cron, class: 'ScheduleBuildJob'})
  end

  def remove_build_schedule
    Sidekiq.remove_schedule(schedule_name)
  end

  def schedule_name
    "environment_schedule_build_#{id}"
  end

end
