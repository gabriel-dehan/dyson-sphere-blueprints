source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.1.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 6.1.3"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.0"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"
# Use Active Model has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

# Lock to psych < 4 until we can update to Rails 7
gem "psych", "< 4"

gem "devise", github: "heartcombo/devise", branch: "master"
gem "pundit"

gem "autoprefixer-rails"
gem "font-awesome-sass"
gem "simple_form"
gem "friendly_id", "~> 5.4.0"
gem "acts_as_votable"
gem "acts-as-taggable-on", "~> 7.0"
gem "awesome_print"
gem "sidekiq"
gem "sidekiq-failures", "~> 1.0"
gem "kaminari"
gem "pg_search"
gem "omniauth-rails_csrf_protection"
gem "omniauth-discord"

gem "aws-sdk-s3", "~> 1.14"
gem "shrine", "~> 3.3"
gem "image_processing", "~> 1.10"
gem "fastimage"
gem "marcel"
gem "dsp_blueprint_parser", "~> 0.1"
gem "rubyzip", require: "zip"
gem "scout_apm"
gem "barnes"
gem "profanity-filter", "~> 1.0"
gem "camalian", "~> 0.2.0"

group :development, :test do
  gem "pry-byebug"
  gem "pry-rails"
  gem "dotenv-rails"

  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "memory_profiler"
  gem "derailed_benchmarks"
  gem "bullet"
  gem "rubocop-daemon", require: false

  # Static code analyzer
  gem "rubocop", "1.19.1"
  gem "rubocop-performance", "1.11.5"
  gem "rubocop-rails", "2.11.3"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 3.26"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
end

group :staging, :production do
  gem "sentry-ruby"
  gem "sentry-rails"
  gem "sentry-sidekiq"
  gem "puma_worker_killer"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "sys-proctable", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "webrick", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
