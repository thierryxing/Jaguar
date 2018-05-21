module VersionHandler

  extend ActiveSupport::Concern

  # Get current app version by different platform and type
  def current_version
    begin
      return '' unless work_dir.present?
      if project.ios?
        if project.lib?
          podspec_file = FileTools.parse_podspec(work_dir)
          podspec_file.version_value
        else
          plist = FileTools.parse_plist(work_dir)
          if plist.present?
            plist['CFBundleShortVersionString'] || ''
          else
            ''
          end
        end
      elsif project.android?
        if project.lib?
          properties = current_gradle_properties
          properties[:VERSION_NAME]
        else
          properties = current_version_properties
          properties[:'version.name']
        end
      else
        ''
      end
    rescue => e
      logger.error(e)
      logger.error(e.backtrace.join("\n"))
      ''
    end
  end

  def next_version
    ''
  end

  # Load gradle.properties as string
  def current_gradle_properties
    begin
      FileTools.parse_gradle_properties(work_dir)
    rescue
      ''
    end
  end

  # Load version.properties as string
  def current_version_properties
    begin
      FileTools.parse_version_properties(work_dir)
    rescue
      ''
    end
  end

end