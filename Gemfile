source 'https://rubygems.org'

# Use this version of ruby (rvm will use this line)
ruby "2.3.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
#gem 'rails', '4.2.7'
gem 'rails', '~> 5.0.1'

gem 'rack-cors'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
#gem 'pg', '~> 0.15'
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', :platform => :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', :require => false
end

group :development do
  gem 'capistrano', '3.4.1'
  gem 'capistrano-rails', '~> 1.1.5'
  gem 'capistrano-passenger' #For passenger specific projects
  gem 'capistrano-bundler', '~> 1.1.2' #To be able to run bundle install on deploy
  gem 'capistrano-rvm' # För att hantera ruby version vid deploy
end

gem 'active_model_serializers'
# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'prawn'
gem 'prawn-table'
gem 'rest-client'
gem 'auto_strip_attributes'
gem 'nilify_blanks'
gem 'barby'
gem 'will_paginate'
gem 'responders'

group :development, :test do
  gem 'rspec-rails', '~> 3.6'
  gem "factory_girl_rails"
end

group :test do
  gem 'webmock'
  gem 'shoulda'
end
