Rails.application.routes.draw do

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  resources :wardrobe_items do
    collection do
      get :search
    end
  end
  resources :outfits
  resources :outfit_suggestions, only: [:index, :new, :create, :show]
  resource :user_profile, only: [:new, :create, :edit, :update]

  # Subscriptions / Pricing
  resources :subscriptions, only: [:new, :create] do
    collection do
      get :success
      get :cancel
      post :webhook
      post :cancel_subscription
      post :reactivate
      get :portal
    end
  end

  # Wardrobe Image Search (Premium Feature)
  resources :wardrobe_searches, only: [:new, :create]

  # Admin Dashboard
  namespace :admin do
    root to: "dashboard#index"

    resources :users, only: [:index, :show] do
      member do
        patch :update_tier
      end
    end

    get "metrics/subscriptions", to: "metrics#subscriptions"
    get "metrics/usage", to: "metrics#usage"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "pages#home"
end
