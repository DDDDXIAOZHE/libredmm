# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#index"
  get "/search", to: "pages#search"

  resources :movies, param: :code, only: %i[index show destroy] do
    put "vote", to: "votes#update"
    delete "vote", to: "votes#destroy"
  end

  resources :resources, only: %i[show destroy]

  get "rss/torrents.rss", to: "rss#torrents", format: false, as: "torrents"

  resources(
    :users,
    param: :email,
    constraints: { user_email: /.+/ },
    only: [],
  ) do
    get "votes.codes", to: "votes#index", format: false, as: :vote_codes
    get "votes.user.js", to: "votes#index", format: false, as: :vote_user_js
    get "pipe.rss", to: "rss#pipe", format: false
  end
end
