module FastfileHandler

  extend ActiveSupport::Concern

  APP_IDENTIFIER_PLACE_HOLDER = '[[APP_IDENTIFIER]]'
  APPLE_ID_PLACE_HOLDER = '[[APPLE_ID]]'
  DEV_PORTAL_TEAM_ID_PLACE_HOLDER = '[[DEV_PORTAL_TEAM_ID]]'
  USERNAME_PLACE_HOLDER = '[[USERNAME]]'
  FASTFILE_PATH_PLACE_HOLDER = '[[FASTFILE_PATH]]'

  def init_fastfiles
    files = [
        {name: 'Fastfile', title: 'Fastfile'},
        {name: 'Appfile', title: 'Appfile'},
        {name: 'Deliverfile', title: 'Deliverfile'}
    ]
    unless File::directory?(File.join(work_dir, 'fastlane'))
      FileUtils.cp_r(File.join(Jaguar::TEMPLATE_PATH, project.platform, project.type, 'fastlane'), work_dir)
    end
    files.each do |file|
      path = File.join(work_dir, 'fastlane', file[:name])
      unless File.exist?(path)
        FileUtils.touch(path)
      end
      file[:content] = File.read(path)
      case file[:name]
        when 'Appfile'
          file[:content] = handle_appfile(file[:content])
        when 'Deliverfile'
          file[:content] = handle_deliverfile(file[:content])
        when 'Fastfile'
          file[:content] = handle_fastfile(file[:content])
        else
          ''
      end
      update_fastfile(file[:name], file[:content])
    end
    files
  end

  # Update content of specific fastfile
  def update_fastfile(file_name, content)
    file = File.open(File.join(fastlane_dir, file_name), "w")
    file.write(content)
    file.close
  end

  private

  def handle_appfile(content)
    content
        .gsub(APP_IDENTIFIER_PLACE_HOLDER, project.identifier || '')
        .gsub(APPLE_ID_PLACE_HOLDER, ENV['FASTLANE_USER'])
        .gsub(DEV_PORTAL_TEAM_ID_PLACE_HOLDER, ENV['FASTLANE_DEV_PORTAL_TEAM_ID'])
  end

  def handle_deliverfile(content)
    content
        .gsub(APP_IDENTIFIER_PLACE_HOLDER, project.identifier || '')
        .gsub(USERNAME_PLACE_HOLDER, ENV['FASTLANE_USER'])
  end

  def handle_fastfile(content)
    if project.ios?
      content.gsub(FASTFILE_PATH_PLACE_HOLDER, ENV['FASTLANE_LOCAL_FASTFILE_PATH_IOS'])
    else
      content.gsub(FASTFILE_PATH_PLACE_HOLDER, ENV['FASTLANE_LOCAL_FASTFILE_PATH_ANDROID'])
    end
  end

end