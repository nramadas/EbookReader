EReader::Application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resources :users, only: [:show, :update] do
    member do
      get 'search_dropbox'
    end
  end
  resources :books, only: [:show]
  resources :chapters, only: [:show]
  resources :book_ownerships, only: [:update]

  root to: "users#show"
end