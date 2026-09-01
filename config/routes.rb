Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :products, only: [ :index, :show ]
      resources :customers, only: [ :index, :show, :create ]
      resources :orders, only: [ :index, :show, :create ] do
        member do
          patch :status
        end
      end
    end
  end
end
