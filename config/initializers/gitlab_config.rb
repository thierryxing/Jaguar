Gitlab.configure do |config|
  config.endpoint = ENV['GITLAB_URL'] # API endpoint URL, default: ENV['GITLAB_API_ENDPOINT']
  config.private_token = ENV['GITLAB_PRIVATE_TOKEN'] # user's private token or OAuth2 access token, default: ENV['GITLAB_API_PRIVATE_TOKEN']
  # Optional
  # config.user_agent   = 'Custom User Agent'          # user agent, default: 'Gitlab Ruby Gem [version]'
  # config.sudo         = 'user'                       # username for sudo mode, default: nil
end