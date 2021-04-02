Sentry.init do |config|
    config.dsn = 'https://f3623adfa9a4432495266b42dd141b4d@o563551.ingest.sentry.io/5703636'
    config.breadcrumbs_logger = [:sentry_logger]
  end