require 'rails/generators'

module WithEmberApp
  module Generators
    class InitializerGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc 'Creates a sample WithEmberApp initializer.'

      def create_initializer
        copy_file 'with_ember_app.rb', 'config/initializers/with_ember_app.rb'
      end
    end
  end
end
