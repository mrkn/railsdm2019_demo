Rails.application.routes.draw do
  root to: 'viewer#index'

  resources :signals, only: [:create]

  resource :model, only: [:show], controller: 'model'
end
