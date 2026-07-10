Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :messages, only: [ :create, :show ]
      resources :reactions, only: [ :create ]
      resources :communities, only: [ :index, :show ]
      resources :sessions, only: [ :create ]

      delete "reactions", to: "reactions#destroy"
      get "communities/:id/messages/top", to: "communities#top_messages"
      get "analytics/suspicious_ips", to: "analytics#suspicious_ips"
    end
  end
end
