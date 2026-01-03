if defined?(Rack::MiniProfiler)
  if Rails.root.join("tmp/caching-dev.txt").exist?
    Rack::MiniProfiler.config.enabled = false
  elsif Rails.env.development?
    Rack::MiniProfiler.config.position = "bottom-right"
  end
end
