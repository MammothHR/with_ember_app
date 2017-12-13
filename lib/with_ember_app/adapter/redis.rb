module WithEmberApp
  module Adapter
    class Redis < Base
      # @param [String]  app_name
      # @param [Boolean] canary
      # @return [String]
      def fetch(app_name, canary: false)
        payload = fetch_payload app_name, canary

        payload[:data] if payload.present?
      end

      # @param [String]  app_name
      # @param [String]  data
      # @param [Boolean] canary
      def write(app_name, data, canary: false)
        if data.present?
          prepped_data = if WithEmberApp.url_prep.respond_to? :call
            WithEmberApp.url_prep.call data
          else
            data
          end

          write_payload app_name, canary, prepped_data
        end
      end

      # @param [String]  app_name
      # @param [Boolean] canary
      # @return [Integer]
      def fetch_version(app_name, canary: false)
        payload = fetch_payload app_name, canary
        payload[:timestamp] if payload.present?
      end

      private

      # @param [String]  app_name
      # @param [Boolean] canary
      # @return [String]
      def cache_key(filename, canary)
        params = ['ember', filename]

        params << 'canary' if canary
        params.join('-')
      end

      # @param [String]  app_name
      # @param [Boolean] canary
      # @return [Hash]
      def fetch_payload(app_name, canary)
        cache_key = cache_key app_name, canary

        Rails.cache.fetch cache_key
      end

      # @param [String]  app_name
      # @param [Boolean] canary
      # @param [Hash]    data
      # @return [Void]
      def write_payload(app_name, canary, data)
        payload = {
          data: data,
          timestamp: Time.now.to_i
        }
        cache_key = cache_key app_name, canary

        Rails.cache.write cache_key, payload
      end
    end
  end
end
