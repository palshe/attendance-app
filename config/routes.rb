Rails.application.routes.draw do
  root "static_pages#home"
  post '/attendance', to: 'attendances#attendance'
end
