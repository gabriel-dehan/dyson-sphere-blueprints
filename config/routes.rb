Rails.application.routes.draw do
  root to: "pages#home"

  get "help", to: "pages#help"
  get "supportus", to: "pages#support"
  get "walloffame", to: "pages#wall_of_fame"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks", registrations: "registrations" }

  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  authenticate :user do
    mount Shrine.presign_endpoint(:cache) => "/s3/params"
  end
  mount PictureUploader.derivation_endpoint => "/derivations/image"

  resources :users, only: [] do
    get :blueprints, to: "users#blueprints"

    collection do
      get :blueprints, to: "users#my_blueprints"
      get :collections, to: "users#my_collections"
      get :favorites, to: "users#my_favorites"
    end
  end

  namespace :blueprint do
    resources :factories, only: [:new, :edit, :create, :update]
    resources :dyson_spheres, only: [:new, :edit, :create, :update]
    resources :mechas, only: [:new, :edit, :create, :update] do
      collection { post :analyze, to: "mechas#analyze" }
    end
  end

  resources :blueprints, only: [:index, :show, :destroy] do
    member do
      put "like", to: "blueprints#like"
      put "unlike", to: "blueprints#unlike"
      put "track", to: "blueprints#track"
    end
  end
  resources :collections, only: [:new, :show, :index, :edit, :create, :update, :destroy] do
    member do
      get "bulk_download", to: "collections#bulk_download"
    end
  end

  resources :tags, only: [:create, :index] do
    collection { post :profanity_check, to: "tags#profanity_check" }
  end
end
