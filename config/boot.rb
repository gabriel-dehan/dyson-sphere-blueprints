ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Load dotenv early to ensure env vars are available for database.yml
require "dotenv"
Dotenv.load

# Add lib/ to load path for Ruby 3.2+ compatibility workarounds
$LOAD_PATH.unshift(File.expand_path("../lib", __dir__)) unless $LOAD_PATH.include?(File.expand_path("../lib", __dir__))
require "logger" # Required for Ruby 3.2+ compatibility with Rails 6.1
require "digest/md5" # Required for dsp_blueprint_parser compatibility with Ruby 3.2+
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
