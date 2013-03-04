EReader::Application.routes.draw do
  devise_for :users

  resources :users, only: [:show, :update]
  resources :books, only: [:show]
  resources :chapters, only: [:show]

  root to: "users#show"

  
end