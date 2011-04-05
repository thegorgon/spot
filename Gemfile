source 'http://rubygems.org'

gem 'rails', '3.0.3'
gem 'capistrano'
gem 'haml'
gem 'jammit'
gem "paperclip", "~> 2.3"
gem "curb"
gem "nokogiri"
gem 'mysql2'
gem 'will_paginate', "~> 3.0.pre2"
gem 'aws-s3', :require => "aws/s3"
gem 'aws-ses', '~> 0.3.2', :require => 'aws/ses'
gem 'redis'
gem 'redis-store', '1.0.0.beta4'
gem 'warden'
gem 'rails_warden'
gem 'yajl-ruby'
gem 'thinking-sphinx', '2.0.0', :require => 'thinking_sphinx'
gem 'ts-resque-delta', '0.0.4', :require => 'thinking_sphinx/deltas/resque_delta'
gem 'resque'
gem 'amatch'
gem 'twitter'
gem 'typhoeus'
gem 'oauth'
gem 'faraday'
gem 'sinatra', '1.1.3'
gem 'geoip'
gem 'rack-ssl-enforcer'

group :production do
  gem 'unicorn'
end

group :development, :test do
  gem 'ruby-debug19'
  gem 'mongrel', '1.2.0.pre2'
end

group :test do
  gem 'resque_spec'
  gem "rspec-rails", "~> 2.4"
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'autotest'
  gem 'autotest-fsevent'
  gem 'autotest-growl'
end
