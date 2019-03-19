Rails.application.routes.draw do
  root to: 'viewer#index'

  resources :signals, only: [:create]
end
