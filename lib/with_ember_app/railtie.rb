require 'with_ember_app/helper'

module WithEmberApp
  class Railtie < Rails::Railtie
    initializer 'with_ember_app.view_helpers' do
      ActionView::Base.send :include, WithEmberApp::Helper
    end
  end
end
