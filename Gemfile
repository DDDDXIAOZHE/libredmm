source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails'

gem 'administrate'
gem 'aws-sdk'
gem 'aws-sdk-rails'
gem 'bootstrap'
gem 'chronic'
gem 'clearance'
gem 'coffee-rails'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'mechanize'
gem 'octicons_helper'
gem 'pg'
gem 'puma'
gem 'sass-rails'
gem 'sendgrid-ruby'
gem 'turbolinks'
gem 'uglifier'

gem 'rack-mini-profiler'

gem 'flamegraph'
gem 'memory_profiler'
gem 'stackprof'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'codecov', require: false
  gem 'database_cleaner'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'webmock'
end

group :development do
  gem 'listen'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end
