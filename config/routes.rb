Rails.application.routes.draw do
  root 'pages#index'
  get 'search', as: :search, to: redirect { |path_params, req|
    "/movies/#{req.GET['q']}"
  }

  resources :movies, only: [:index, :show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
