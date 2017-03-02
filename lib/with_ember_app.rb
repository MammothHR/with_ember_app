require 'active_support'
require 'active_support/core_ext'
require 'attr_lazy'
require 'active_interaction'
require 'slim'
require 'action_view'

require 'with_ember_app/version'
require 'with_ember_app/cache'
require 'with_ember_app/authentication'
require 'with_ember_app/file_writer'
require 'with_ember_app/assets/builder'
require 'with_ember_app/assets/defaults'
require 'with_ember_app/engine' if defined?(Rails::Engine)
require 'with_ember_app/railtie' if defined?(Rails::Railtie)

module WithEmberApp
  mattr_accessor :loading_classes
  self.loading_classes = nil

  mattr_accessor :error_classes
  self.error_classes = nil

  mattr_accessor :error_hide_class
  self.error_hide_class = 'hide'

  mattr_accessor :url_prep
  self.url_prep = nil

  mattr_accessor :timeout_period
  self.timeout_period = 10000

  mattr_accessor :deploy_key
  self.deploy_key = nil

  # @private
  mattr_accessor :_custom_asset_rules
  self._custom_asset_rules = {}.with_indifferent_access

  class << self
    delegate :write, :fetch, :fetch_version, to: :cache

    attr_lazy_reader :cache do
      Cache.new(self)
    end

    def setup
      yield self
    end

    # @see WithEmberApp::Assets::Defaults
    # @param [String]  app_name
    # @param [{string => {String => String,Boolean}}] canary
    # @return [void]
    def add_custom_default_asset_rules_for(app_name, **kwargs)
      rule = {}
      rule[app_name] = kwargs

      self._custom_asset_rules.merge! rule
    end
  end
end

