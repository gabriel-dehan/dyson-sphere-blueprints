Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users
  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  resources :users, only: [] do
    resources :blueprints, only: [:index]
  end
  resources :blueprints, only: [:index, :new, :show, :edit, :create, :update, :destroy] do
    member do
      put 'like', to: "blueprints#like"
      put 'unlike', to: "blueprints#unlike"
    end
  end
  resources :collections, only: [:index, :new, :show, :edit, :create, :update, :destroy]
end
