Sentry.init do |config|
  config.dsn = 'https://ff4f5ac06c4b4f60825b83a8e09f180a@o553856.ingest.sentry.io/5681674'
  config.breadcrumbs_logger = [:active_support_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end