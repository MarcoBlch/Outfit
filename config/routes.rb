Rails.application.routes.draw do
  # Landing page (unauthenticated)
  root to: 'landing#index'

  # Authenticated app (after login)
  authenticated :user do
    root to: 'pages#home', as: :authenticated_root
  end

  # Legal pages
  get 'privacy', to: 'pages#privacy', as: :privacy
  get 'terms', to: 'pages#terms', as: :terms

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
  resources :outfit_suggestions, only: [:index, :new, :create, :show] do
    member do
      get :show_recommendations
      post 'recommendations/:recommendation_id/record_view', to: 'outfit_suggestions#record_view', as: :record_recommendation_view
      post 'recommendations/:recommendation_id/record_click', to: 'outfit_suggestions#record_click', as: :record_recommendation_click
    end
  end
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

    resources :product_recommendations, only: [:index]

    get "metrics/subscriptions", to: "metrics#subscriptions"
    get "metrics/usage", to: "metrics#usage"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoints for Railway deployment monitoring
  # Simple health check (default Rails)
  get "up" => "rails/health#show", as: :rails_health_check

  # Custom health checks with more detail
  get "health" => "health#show"              # Simple: just returns 200
  get "health/detailed" => "health#detailed" # Detailed: includes DB checks
  get "health/ready" => "health#ready"       # Readiness: app ready to serve traffic
  get "health/live" => "health#live"         # Liveness: app is responsive

  # Defines the root path route ("/")
  # Root is now defined at the top (landing#index for logged out, pages#home for logged in)
end
