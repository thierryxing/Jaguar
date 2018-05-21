require 'fastlane/helper/podspec_helper'

module FileTools
  extend self

  # Returns dir which include .xcodeproj file.
  def get_xcode_dir(path)
    get_dir(path, 'xcodeproj')
  end

  # Returns dir which include .git dir.
  def get_git_dir(path)
    get_dir(path, '', '.git')
  end

  # Returns dir which include fastlane folder
  def get_fastlane_dir(path)
    Dir.glob(File.join(path, '**', 'fastlane')) do |dir|
      return File.dirname(dir)
    end
  end

  # Returns dir which include Info.plist file
  def plist(path)
    xcode_path = FileTools.get_xcode_dir(path)
    unless xcode_path.present?
      return ''
    end
    plist_list = Dir[File.join(xcode_path, '*', 'Info.plist')]
    if plist_list.count > 0
      plist_list.first
    else
      ''
    end
  end

  # Returns parse plist xml file
  def parse_plist(path)
    plist_file_path = self.plist(path)
    if plist_file_path.present?
      Plist.parse_xml(plist_file_path)
    else
      ''
    end
  end

  # Returns dir which include .podspec file
  def get_podspec_dir(path)
    get_dir(path, 'podspec')
  end

  # Returns path which include .podspec file
  def get_podspec_path(path)
    path = FileTools.get_podspec_dir(path)
    if path.present?
      Dir[File.join(FileTools.get_podspec_dir(path), '*.podspec')].first
    else
      ''
    end
  end

  # Returns parse podspec file
  def parse_podspec(path)
    podspec_path = get_podspec_path(path)
    Fastlane::Helper::PodspecHelper.new(podspec_path)
  end

  # Returns parse java gradle.properties file
  def parse_gradle_properties(path)
    JavaProperties.load(File.join(path, "gradle.properties"))
  end

  # Returns parse version.properties file
  def parse_version_properties(path)
    version_file_path = get_dir(path, 'properties', 'version')
    JavaProperties.load(File.join(version_file_path, "version.properties"))
  end

  # Returns parse podfile and get dependencies from it
  def parse_podfile_dependencies(path)
    podfile_dir = get_dir(path, 'lock', 'Podfile')
    podfile = File.join(podfile_dir, 'Podfile.lock')
    data = File.read(podfile)
    dependencies = data.split('DEPENDENCIES:')[0]
    dependencies.scan /- (\S+) \(([\.\d]+)+\)/
  end

  # Returns parse gradle and get dependencies from it
  def parse_gradle_dependencies(path)
    # if find lego.gradle then use it else use build.gradle
    gradle_dir = get_dir(path, 'gradle', 'lego')
    if gradle_dir
      file = File.join(gradle_dir, 'lego.gradle')
    else
      file = File.join(get_dir(path, 'gradle', 'build'), 'build.gradle')
    end
    data = File.read(file)
    dependencies = data.split('dependencies')[1]
    dependencies.scan /compile \'([\.\-\:\w\d]+):([\.\d]+[\-SNAPSHOT]*)\'/
  end

  # Create dir if not exist one and return this dir
  def mkdir_if_not_exist(dir)
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    dir
  end

  # Create file if not exist one and return this file
  def touch_if_not_exist(file)
    FileUtils.touch(file) unless File.exist?(file)
    file
  end

  # Render syntax highlight log file to web
  #
  # @param  [String] data Origin log data
  # @return [String] rendered html
  def escape_ansi_to_html(data)
    {1 => :nothing,
     2 => :nothing,
     4 => :underline,
     5 => :nothing,
     7 => :nothing,
     30 => :black,
     31 => :red,
     32 => :green,
     33 => :yellow,
     34 => :blue,
     35 => :magenta,
     36 => :cyan,
     37 => :white,
     39 => :bold,
     40 => :nothing
    }.each do |key, value|
      if value != :nothing
        data.gsub!(/\e\[#{key}m/, "<span class=\"#{value}\">")
      else
        data.gsub!(/\e\[#{key}m/, "<span>")
      end
    end
    data.gsub!('[39;1m', '')
    data.gsub!(/\e\[0m/, '</span>')
    data
  end

  private

  def get_dir(path, suffix='', file_name = '*')
    begin
      file_name = "#{file_name}.#{suffix}" unless suffix.blank?
      Dir.glob(File.join(path, '**', file_name)) do |dir|
        return File.dirname(dir)
      end
    rescue Exception => e
      Rails.logger.error(e.message)
      ""
    end
  end

end