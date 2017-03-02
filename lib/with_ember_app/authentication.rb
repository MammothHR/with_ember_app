module WithEmberApp
  module Authentication
    class << self
      # @return [Boolean]
      def authenticate(key)
        validate_current_key!

        key.present? &&  key == current_key
      end

      private

      # @return [String]
      def current_key
        WithEmberApp.deploy_key
      end

      # @return [void]
      def validate_current_key!
        raise 'Error: no deploy key set for WithEmberApp!' unless current_key.present?
      end
    end
  end
end
