module WithEmberApp
  module Adapter
    class Base
      attr_reader :options

      # @param [WithEmberApp]  options
      def initialize(options)
        @options = options
      end

      # @param [String]  app_name
      # @param [Boolean] canary
      # @return [String]
      def fetch(app_name, canary: false)
        raise NotImplementedError
      end

      # @param [String]  app_name
      # @param [String]  data
      # @param [Boolean] canary
      def write(app_name, data, canary: false)
        raise NotImplementedError
      end

      # @param [String]  app_name
      # @param [Boolean] canary
      # @return [Integer]
      def fetch_version(app_name, canary: false)
        raise NotImplementedError
      end
    end
  end
end
