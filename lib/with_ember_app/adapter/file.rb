# Asset rules for generating asset links in development.
# Current rules supported:
#   vendor:         - whether to include vendor or not (default true)
#   app:            - whether to include app or not (default true)
#   css:            - whether to include css or not (default true)
#   prefix_vendor:  - whether to prefix vendor assets with app name (default true)
module WithEmberApp
  module Adapter
    class File < Base
      attr_reader :app_name

      class IndexNotFound < StandardError
      end

      # @param [String]  app_name
      # @param [Boolean] canary
      # @return [String]
      def fetch(app_name, canary: false)
        @app_name = app_name

        url = app_rules[:dev_index]

        if url.present?
          ::File.read url
        elsif can_infer_index?
          ::File.read inferred_index_file
        elsif !options.raise_if_index_not_found
          generate_default_payload
        else
          raise IndexNotFound,  "WithEmberAppError: attempted to find an index file at #{ url } and #{ inferred_index_file } and neither was readable."
        end
      end

      # @return [Integer]
      def fetch_version(*_)
        Time.now.to_i
      end

      private

      # @return [Hash]
      def app_rules
        rules[app_name.to_s.underscore] || {}
      end

      # @return [Hash]
      def rules
        options._custom_asset_rules
      end

      def can_infer_index?
        inferred_index_file.present? && ::File.file?(inferred_index_file)
      end

      def inferred_index_file
        dasherized_name = app_name.to_s.dasherize
        dist_path = app_rules[:dist_path].presence || Rails.root.join('..', dasherized_name, 'dist')

        dist_path.join "#{ dasherized_name }.html"
      end

      # @!group Default Payload Generation
      # @note This will try and generate an equivalent html file for this app
      # @note This will not add meta tags or payload information, so Engines cannot work
      # @return [String]
      def generate_default_payload
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

      def include_app?
        rule_not_present_or_true? :app
      end

      def include_vendor?
        rule_not_present_or_true? :vendor
      end

      def include_css?
        rule_not_present_or_true? :css
      end

      def prefix_vendor?
        rule_not_present_or_true? :prefix_vendor
      end

      def rule_not_present_or_true?(rule)
        value = matching_rule[rule]

        value.nil? || value
      end

      # @return [Hash]
      def matching_rule
        rules[app_name] || {}
      end

      # @return [String]
      def javascript_tag(file)
        "<script src=\"/assets/#{ file }.js\" type=\"text/javascript\"></script>"
      end

      # @return [String]
      def stylesheet_tag(file)
        "<link rel=\"stylesheet\" type=\"text/css\" href=\"/assets/#{ file }.css\">"
      end
      # @!endgroup
    end
  end
end
