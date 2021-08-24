if ENV["REDISCLOUD_URL"]
  redis = { url: ENV["REDISCLOUD_URL"] }
  Sidekiq.configure_server { |config| config.redis = redis }
  Sidekiq.configure_client { |config| config.redis = redis }
end
