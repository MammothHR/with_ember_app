module WithEmberApp
  module Assets
    class Builder < ActiveInteraction::Base
      # When building for a single app
      string  :name, default: nil
      # When building for multiple apps
      array   :names, default: -> { [] }
      hash    :globals, strip: false, default: -> { {} }

      validate :all_names_present

      # @return [String]
      def execute
        [globals_as_js, asset_links].flatten.join.html_safe
      end

      private

      def all_names_present
        unless all_names.present?
          self.errors.add :name, 'Must include either a name or names'
        end
      end

      # @note Flatten out name / names inputs
      # @return [<String>]
      attr_lazy_reader :all_names do
        names << name if name.present?

        names.reject { |row| row.blank? }
        names
      end

      # @return [<String>]
      def asset_links
        all_names.map { |app| WithEmberApp.fetch app }
      end

      # @return [String]
      def globals_as_js
        "<script type=\"text/javascript\">#{ json_payload_as_globals }</script>"
      end

      # @return [String]
      def json_payload_as_globals
        json_payload.each_pair.map do |(key, value)|
          "window.#{ key } = #{ value.to_json }; "
        end.join
      end

      # @return [Hash]
      def json_payload
        { envName: Rails.env }.merge(globals)
      end
    end
  end
end
