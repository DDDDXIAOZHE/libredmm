# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.6.4"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails"

gem "aws-sdk"
gem "aws-sdk-rails"
gem "bootstrap"
gem "chronic"
gem "clearance"
gem "coffee-rails"
gem "jbuilder"
gem "jquery-rails"
gem "kaminari"
gem "mechanize"
gem "octicons_helper"
gem "pg"
gem "pry-rails"
gem "puma"
gem "sass-rails"
gem "sendgrid-ruby"
gem "turbolinks"
gem "uglifier"
gem "webpacker"

gem "rack-mini-profiler"

gem "flamegraph"
gem "memory_profiler"
gem "stackprof"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "capybara"
  gem "codecov", require: false
  gem "database_cleaner"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "webmock"
end

group :development do
  gem "listen"
  gem "rufo"
  gem "spring"
  gem "spring-watcher-listen"
  gem "travis"
  gem "web-console"
end
