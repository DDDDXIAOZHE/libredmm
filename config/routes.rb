Rails.application.routes.draw do
  namespace :admin do
    resources :movies
    resources :resources
    resources :users
    resources :votes

    root to: 'movies#index'
  end

  root 'pages#index'
  get '/search', to: 'pages#search'

  resources :movies, param: :code, only: %i[index show destroy] do
    put 'vote', to: 'votes#update'
    delete 'vote', to: 'votes#destroy'
  end

  resources :resources, only: %i[show destroy]

  resources(
    :users,
    param: :email,
    constraints: { user_email: /.+/ },
    only: [],
  ) do
    get 'votes.codes', to: 'votes#index', format: false
    get 'votes.user.js', to: 'votes#index', format: false
    get 'pipe.rss', to: 'rss#pipe', format: false
    get 'torrents.rss', to: 'rss#torrents', format: false, as: 'torrents'
  end
end
