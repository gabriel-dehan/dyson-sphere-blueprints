ENV["RAILS_ENV"] ||= "test"

# Suppress PG::Coder deprecation warnings from ActiveRecord 6.1 + pg gem 1.6+
# These warnings come from ActiveRecord's internal code and will be fixed in future versions
module Kernel
  alias original_warn warn

  def warn(*messages, **kwargs)
    filtered = messages.reject { |msg| msg.to_s.include?("PG::Coder.new(hash) is deprecated") }
    original_warn(*filtered, **kwargs) unless filtered.empty?
  end
end

require_relative "../config/environment"
require "rails/test_help"

# Disable Bullet in tests to avoid N+1 query errors
Bullet.enable = false if defined?(Bullet)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Helper to get a sample cover picture for uploads
  def sample_cover_picture
    fixture_file_upload(Rails.root.join("test/fixtures/files/cover.png"), "image/png")
  end

  # Helper to get sample factory blueprint code
  def sample_factory_code
    'BLUEPRINT:0,10,2203,0,0,0,0,0,638229688703249448,0.9.27.15466,Wind%20Turbine%20Row,"H4sIAAAAAAAAC2NkYGAQYkAAVSBmhLIZGf4zMJyACjMysMLU/P/P7wSWnyBpjsyGyc/mMAWqgQAkoyHmsjDccARzLC5vR2YT0swEIpgZBBxhtiGzCWlmhhATIBoOSG5DZhPSzAIiVqnPN4PZhswmpBkAVTZYlGABAAA="69A8C019EDC4ADACB9B4D802E0D4248A'
  end

  # Helper to get sample dyson sphere blueprint code
  def sample_dyson_sphere_code
    'DYBP:0,637790444891173226,0.9.24.11286,3,0"H4sIAAAAAAAAC/v/HwIYGYDAQcaNAQU02DMyoUmIvT+8L645x56RGSrxmcXUHoj3Jx9gMQbizYwsUAmgSjugyv0FG/qN9hbpbmZkGAWDCgAA1Fa3jvwBAAA="D6D62579044FF1FFA85A8E20F7796DE3'
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Set default URL options for tests to handle locale scope
  def default_url_options
    { locale: nil }
  end

  # Sign in as a specific user fixture
  def sign_in_as(user_fixture)
    sign_in users(user_fixture)
  end
end
