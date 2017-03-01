$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'active_support/cache'

module Rails
  class << self
    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new
    end

    def env
      @_env ||= ActiveSupport::StringInquirer.new(ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "test")
    end
  end
end

require "with_ember_app"

RSpec.configure do |config|
  config.after(:each) do
    WithEmberApp.loading_classes = nil
    WithEmberApp.error_classes = nil
    WithEmberApp.error_hide_class = nil
    WithEmberApp.deploy_key = nil
    WithEmberApp.url_prep = nil
    WithEmberApp._custom_asset_rules = {}

    Rails.cache.clear
  end
end
