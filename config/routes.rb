Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  devise_for :admins, skip: [ :registration ]
  devise_for :users
  resources :courses do
    resources :lessons
  end

  authenticated :admin do
    root "admin#index", as: :admin_root
  end

  namespace :admin do
    resources :courses do
      resources :lessons
    end
    resources :users
  end

  authenticated :user do
    root "courses#index", as: :user_root
  end

  resources :checkouts, only: [ :create ]

  post "/webhook" => "webhooks#stripe"

  get "admin", to: "admin#index"

  patch "/admin/courses/:course_id/lessons/:id/move" => "admin/lessons#move"

  root "courses#index"
end
