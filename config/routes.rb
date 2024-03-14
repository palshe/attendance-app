Rails.application.routes.draw do
  root "static_pages#home"
  get "/attendances/create", to: "attendances#create"
  get "/attendances", to: "static_pages#home"
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

  get "/attendance", to: "static_pages#home"
end
