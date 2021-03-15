Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users
  resources :blueprints, only: [:index, :new, :show, :edit, :create, :update, :delete]
  resources :collections, only: [:index, :new, :show, :edit, :create, :update, :delete]
end
