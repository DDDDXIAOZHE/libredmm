Rails.application.routes.draw do
  get 'resources/show'

  root 'pages#index'
  get 'search', as: :search, to: redirect { |_, req|
    "/movies/#{CGI::escape(req.GET['q'])}"
  }

  resources :movies, param: :code, only: %i[index show] do
    put 'vote', to: 'votes#update'
    delete 'vote', to: 'votes#destroy'
  end

  resources :resources, only: :show

  resources :users, param: :email, constraints: { user_email: /.+/ }, only: [] do
    get 'votes.codes', to: 'votes#index', format: false
    get 'votes.user.js', to: 'votes#index', format: false
    get 'pipe.rss', to: 'rss#pipe', format: false
  end
end
