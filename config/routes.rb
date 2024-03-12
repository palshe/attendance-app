Rails.application.routes.draw do
  root "static_pages#home"
  get "/attendance", to: "attendances#create"
  post "/attendance", to: "attendances#attendance"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :workers
  resources :workers do
    member do
      get 'overtime'
    end
  end
end
