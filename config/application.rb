require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Jaguar
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.middleware.use ActionDispatch::Cookies
    config.active_job.queue_adapter = :sidekiq

    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    config.autoload_paths << Rails.root.join('app', 'notifiers')
    config.autoload_paths << Rails.root.join('app', 'observers')
    config.autoload_paths << Rails.root.join('app', 'models', 'environment_service')
    config.autoload_paths << Rails.root.join('lib')
    config.active_record.observers = :environment_observer

    WillPaginate.per_page = 15

    Rails.logger = Sidekiq::Logging.logger

  end
end
