Gitlab.configure do |config|
  config.endpoint = 'http://git.wanmeizhensuo.com/api/v3' # API endpoint URL, default: ENV['GITLAB_API_ENDPOINT']
  config.private_token = 'HTySY4s9G577a-w_xhCc' # user's private token or OAuth2 access token, default: ENV['GITLAB_API_PRIVATE_TOKEN']
  # Optional
  # config.user_agent   = 'Custom User Agent'          # user agent, default: 'Gitlab Ruby Gem [version]'
  # config.sudo         = 'user'                       # username for sudo mode, default: nil
end