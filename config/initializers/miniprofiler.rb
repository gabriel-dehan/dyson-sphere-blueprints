if Rails.root.join("tmp/caching-dev.txt").exist?
  Rack::MiniProfiler.config.enabled = false
else
  Rack::MiniProfiler.config.position = "bottom-right" if Rails.env.development?
end
