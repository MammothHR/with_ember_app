module WithEmberApp
  module Assets
    class Builder < ActiveInteraction::Base
      string  :name, default: nil
      array   :names, default: -> { [] }
      hash    :globals, strip: false, default: -> { {} }

      validate :all_names_present

      def execute
        elements.flatten.join.html_safe
      end

      private

      def options
        WithEmberApp
      end

      def all_names_present
        unless all_names.present?
          self.errors.add :name, 'Must include either a name or names'
        end
      end

      def elements
        [asset_links, raw_javascript]
      end

      attr_lazy_reader :all_names do
        names << name if name.present?

        names.reject { |row| row.blank? }
      end

      def asset_links
        names.map { |app| WithEmberApp.fetch app }.join
      end

      def raw_javascript
        "<script type=\"text/javascript\">#{ json_payload_as_globals }</script>"
      end

      def json_payload_as_globals
        json_payload.each_pair.map do |(key, value)|
          "window.#{ key } = #{ value.to_json }; "
        end.join
      end

      def json_payload
        { envName: Rails.env }.merge(globals)
      end
    end
  end
end
