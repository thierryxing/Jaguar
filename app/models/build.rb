# == Schema Information
#
# Table name: builds
#
#  id             :integer          not null, primary key
#  version        :string
#  status         :integer
#  project_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  build_number   :string
#  job_id         :string
#  release_notes  :string
#  snapshot       :boolean
#  user_id        :integer
#  env_template   :integer
#  environment_id :integer
#

require 'open3'
require 'shellwords'

class Build < ApplicationRecord

  include AbstractController::Rendering
  include Rails.application.routes.url_helpers

  enum status: %i(failed success processing canceled)

  validates :version, presence: true

  belongs_to :project
  belongs_to :environment
  belongs_to :user, optional: true

  has_many :release_notes

  scope :succeed, -> {where status: Build.statuses[:success]}

  def self.init_and_do_build(environment, current_user: nil, version: nil, notes: '')
    build = Build.new
    build.project = environment.project
    build.environment = environment
    build.user = current_user if current_user.present?
    build.version = version.present? ? version : environment.current_version
    build.save

    notes.split(/\r?\n/).each do |content|
      if content.present?
        note = ReleaseNote.new
        note.content = content
        note.build = build
        note.save
      end
    end

    build.start_build_job
    build
  end

  def api_data
    {
        id: id,
        status: status,
        version: version,
        number: build_number,
        updated_at: I18n.l(updated_at),
        release_notes: release_notes,
        operator: user.present? ? {
            id: user.id,
            name: user.name
        } : {},
        environment: environment.present? ? {
            id: environment.id,
            name: environment.name
        } : {},
        project: project.present? ? {
            id: project.id,
            name: project.title
        } : {}
    }
  end

  def start_build_job
    job = BuildJob.perform_later(self)
    update_attribute(:job_id, job.provider_job_id)
  end

  # Do Build Job
  def execute_build_job
    begin
      update_attribute(:status, Build.statuses[:processing])
      execute_command(build_fastlane_cmd)
    rescue => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      self.status = Build.statuses[:failed]
    ensure
      self.save
    end
  end

  # Get delivery log file path.
  #
  # @return [String] log
  def get_build_log
    file = File.join(project.log_file_dir, "#{id}.log")
    FileTools.touch_if_not_exist(file)
  end

  # The final build Dir
  def build_dir
    dir = File.join(project.app_files_dir, version)
    FileTools.mkdir_if_not_exist(dir)
  end

  # The final build file name
  #
  # @return [String] build name like GMDoctor.apk or GMDoctor.ipa
  def build_name
    "#{project.title}_#{environment.id}_#{version}_#{id}"
  end

  # The final build file path
  #
  # @return [String] build name like GMDoctor.apk or GMDoctor.ipa
  def build_file_path
    file_name = build_name
    if project.android?
      file_name << '.apk'
    else
      file_name << '.ipa'
    end
    File.join(build_dir, file_name)
  end

  # Generate build number for different platform
  def generate_build_number
    if project.ios?
      self.build_number = Time.now.strftime('%Y%m%d%H%M')
    elsif project.android?
      if environment.current_version_properties.present?
        self.build_number = environment.current_version_properties[:'version.code']
      else
        self.build_number = ''
      end
    end
    self.save
    self.build_number
  end

  # Build fastlane command
  #
  # @return [String] command
  def build_fastlane_cmd
    cmd = ["fastlane #{environment.fastlane_template.command}"]
    cmd << "version:#{version}"
    cmd << "build_number:#{generate_build_number}"
    cmd << "git_branch:#{environment.git_branch}"
    cmd << "git_tag:#{environment.git_tag}"
    cmd << "work_dir:#{environment.work_dir}"
    if project.android?
      cmd << "android_build_dir:#{build_dir}"
      cmd << "android_origin_apk_name:#{environment.scheme}"
      cmd << "android_final_apk_name:#{build_name}.apk"
      cmd << "android_package_name:#{project.identifier}"
    end
    if project.ios?
      cmd << "ios_scheme:#{environment.scheme}"
      cmd << "ios_output_directory:#{build_dir}"
      cmd << "ios_output_name:#{build_name}"
      cmd << "ios_bundle_identifier:#{project.identifier}"
      cmd << "ios_plist_file:#{FileTools.plist(environment.env_dir)}"
      cmd << "ios_podspec_path:#{FileTools.get_podspec_path(environment.env_dir)}"
    end
    cmd.join(' ')
  end

  # Execute Shell Command
  def execute_command(cmd)
    result = CommandTools.run_deliver_command(environment.work_dir, cmd, get_build_log)
    self.status = result ? Build.statuses[:success] : Build.statuses[:failed]
    self.save
    reset_git
    publish
    notification
  end

  # Reset local changes in case trigger some git error in next build like：
  # "Your local changes to the following files would be overwritten by checkout"
  def reset_git
    git = Git.open(environment.git_dir)
    git.reset_hard
  end

  def notification
    begin
      environment.active_notification_services.each do |service|
        service.execute(self)
      end
    rescue Exception => e
      logger_exception(e)
    end
  end

  def publish
    begin
      environment.active_publish_services.each do |service|
        service.execute(self)
      end
    rescue Exception => e
      logger_exception(e)
    end
  end

end
