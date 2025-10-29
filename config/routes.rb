require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  
  resources :products
  
  resource :cart, only: %i[create show] do
    post :add_item
    delete ":product_id", to: "carts#destroy"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
