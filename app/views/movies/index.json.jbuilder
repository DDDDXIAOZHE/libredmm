# frozen_string_literal: true

json.array! @movies, partial: 'movies/movie', as: :movie
