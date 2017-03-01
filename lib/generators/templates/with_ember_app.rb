WithEmberApp.setup do |config|
  # Deploy key for validating deploys
  # config.deploy_key = '585db5171c59a47f68b0de27b8c40c2341b52cdbc60d3083d4e8958532'

  # HTML to include in the loading message
  # config.loading_message = nil

  # HTML to include in the error message
  # config.error_message = nil

  # CSS classes to add to the loading element
  # config.loading_classes = nil

  # CSS classes to add to the error element
  # config.error_classes = nil

  # CSS class to hide the error text
  # config.error_hide_class = 'hide'

  # Callback for preparing asset URLs
  # By default all assets are prefixed with /assets/
  # This allows manipulating that, for example if you use a CDN.
  #
  # config.url_prep = ->(data) {
  #   data.gsub('/assets', my_cloudfront_url_prefix)
  # }

  # Timeout period before error message appears (in ms)
  # config.timeout_period = 10000
end
