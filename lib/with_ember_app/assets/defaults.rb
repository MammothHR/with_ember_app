module WithEmberApp
  module Assets
    class Defaults
      attr_reader :options, :app_name

      def initialize(options, app_name)
        @options = options
        @app_name = app_name
      end

      def to_s
        [].tap do |result|
          if include_vendor?
            vendor_name = if prefix_vendor?
              app_name + '-vendor'
            else
              'vendor'
            end

            result << javascript_tag(vendor_name)
            result << stylesheet_tag(vendor_name) if include_css?
          end

          if include_app?
            result << javascript_tag(app_name)
            result << stylesheet_tag(app_name) if include_css?
          end
        end.join
      end

      private

      def rules
        options._custom_asset_rules
      end

      def matching_rule
        rules[app_name] || {}
      end

      def include_app?
        rule_not_present_or_true :app
      end

      def include_vendor?
        rule_not_present_or_true :vendor
      end

      def include_css?
        rule_not_present_or_true :css
      end

      def prefix_vendor?
        rule_not_present_or_true :prefix_vendor
      end

      def rule_not_present_or_true(rule)
        value = matching_rule[rule]

        value.nil? || value
      end

      # @TODO replace with Rails helper
      def javascript_tag(file)
        "<script src=\"/assets/#{ file }.js\" type=\"text/javascript\"></script>"
      end

      # @TODO replace with Rails helper
      def stylesheet_tag(file)
        "<link rel=\"stylesheet\" type=\"text/css\" href=\"/assets/#{ file }.css\">"
      end
    end
  end
end
