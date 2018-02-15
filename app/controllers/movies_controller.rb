class MoviesController < ApplicationController
  # GET /movies
  # GET /movies.json
  def index
    @filter = params[:filter]
    case @filter
    when 'downvoted'
      @movies = signed_in? ? current_user.downvoted_movies : Movie.none
    when 'upvoted'
      @movies = signed_in? ? current_user.upvoted_movies : Movie.none
    when 'unvoted'
      @movies = signed_in? ? current_user.unvoted_movies : Movie.all
    else
      @movies = Movie.all
      @filter = 'all'
    end
    @movies = @movies.order(code: :asc).page(params[:page])
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    @movie = Movie.find_or_create_by(code: params[:id])
    redirect_to id: @movie.code if @movie.code != params[:id]
  end
end
