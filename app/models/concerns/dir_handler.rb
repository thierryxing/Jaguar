module DirHandler

  extend ActiveSupport::Concern

  # Each environment has one dir which named name
  def env_dir
    dir = File.join(project.project_dir, self.name)
    FileTools.mkdir_if_not_exist(dir)
  end

  # Each environment has one git_dir which named #{project.title}
  def git_dir
    FileTools.get_git_dir(env_dir)
  end

  def git_dir_exist?
    git_dir and Dir.exist?(git_dir)
  end

  # Each environment has one work_dir
  def work_dir
    dir = git_dir
    if project.ios?
      dir = project.app? ? FileTools.get_xcode_dir(dir) : FileTools.get_podspec_dir(dir)
    end
    dir
  end

  # Each environment has one fastlane_dir which contains fastlane dir
  def fastlane_dir
    dir = File.join(work_dir, 'fastlane')
    FileTools.mkdir_if_not_exist(dir)
  end

  # Copy folder from one exist environment
  def cp_dir(environment)
    FileUtils.cp_r(File.join(environment.env_dir, "."), env_dir)
  end

  # Android mapping files dir
  def mapping_dir
    File.join(work_dir, main_module, 'build', 'outputs', 'mapping', gradle_task)
  end


end