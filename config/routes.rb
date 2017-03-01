Rails.application.routes.draw do
  mount WithEmberApp::Engine => '/with_ember_app'
end

WithEmberApp::Engine.routes.draw do
  scope module: 'with_ember_app' do
    resources :app, only: [:create]
  end
end
