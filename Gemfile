source 'https://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'pg'
end

group :development, :test do
  gem 'mysql2'
  gem 'rspec-rails', '~> 2.8'
  gem 'rspec-instafail'
  gem 'capybara'
  gem 'factory_girl_rails'

  gem 'guard'
  gem 'guard-rspec'
  gem 'ruby_gntp'
  gem 'awesome_print'
  gem 'heroku'
end

group :test do
  gem 'mocha'
  gem 'webmock'
  gem 'valid_attribute'
  gem 'vcr', '~> 2.0'
  gem 'timecop'
end

gem 'squeel'
gem 'json'
gem 'haml-rails'
gem 'jquery-rails'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'exception_notification'
gem 'omniauth', '~> 1.0.2'
gem 'omniauth-facebook', '~> 1.2.0'
# gem 'omniauth-twitter'
gem 'simple_form'
gem 'configuration'
gem 'stringex'
gem 'jbuilder'
gem 'kaminari'
gem 'validates_email_format_of'

gem 'simple_admin', :git => 'git://github.com/zapnap/simple_admin.git', :branch => 'rails-3-2'
gem 'formtastic' # icky, for simple_admin (todo: replace with simple_form)

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'
