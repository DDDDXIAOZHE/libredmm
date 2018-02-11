class MoviesController < ApplicationController
  before_action :set_movie, only: [:show]

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find_or_create_by(code: params[:id])
      if @movie.code != params[:id]
        redirect_to id: @movie.code
      end
    end
end
