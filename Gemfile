source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.6'
gem 'rails-observers', '0.1.5'
gem 'mysql2', '0.4.10'
gem 'puma', '3.11.3'
gem 'redis', '3.3.5'
gem 'fastlane', '2.91.0'
gem 'gitlab', '4.6.1'
gem 'plist', '3.2.0'
gem 'java-properties', '0.2.0'
gem 'dotenv-rails', '2.2.2'
gem 'will_paginate', '3.1.6'
gem 'annotate', '2.7.2'
gem 'sidekiq', '5.0.5'
gem 'sidekiq-scheduler', '2.1.10'
gem 'sinatra', :require => nil
gem 'git', git: 'git@github.com:thierryxing/ruby-git.git', tag: 'v1.3.1'
gem 'dingbot', '0.2.2'

# Fastfile中如果使用Cocoapods的话，需要增加下面的声明
gem 'cocoapods', git: 'git@github.com:thierryxing/CocoaPods.git', branch: 'branch-1.4.1'
# Fastfile中如果使用fir-cli的话，需要增加下面的声明
gem 'fir-cli'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
gem 'sentry-raven', '~> 2.5.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rubocop', '~> 0.52.1', require: false
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
