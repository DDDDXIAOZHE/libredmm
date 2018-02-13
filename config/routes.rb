Rails.application.routes.draw do
  root 'pages#index'
  get 'search', as: :search, to: redirect { |_, req|
    "/movies/#{req.GET['q']}"
  }

  resources :movies, only: %i[index show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
