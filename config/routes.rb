Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users
  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  resources :blueprints, only: [:index, :new, :show, :edit, :create, :update, :delete]
  resources :collections, only: [:index, :new, :show, :edit, :create, :update, :delete]
end
