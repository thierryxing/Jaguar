module Jaguar

  JAGUAR_HOME ||= File.join(Dir.home, '.Jaguar')
  DELIVER_LOG_DIR ||= File.join(JAGUAR_HOME, 'log', 'deliver')
  FASTFILE_DIR ||= File.join(JAGUAR_HOME, 'fastfile')
  APP_FILES ||= File.join(JAGUAR_HOME, 'app_files')
  TEMPLATE_PATH ||= File.join(Rails.root, 'public', 'template')

end