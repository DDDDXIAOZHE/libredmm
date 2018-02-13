class MoviesController < ApplicationController
  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.order(code: :asc).all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    @movie = Movie.find_or_create_by(code: params[:id])
    if @movie.code != params[:id]
      redirect_to id: @movie.code
    end
  end
end
