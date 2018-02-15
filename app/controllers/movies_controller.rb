class MoviesController < ApplicationController
  # GET /movies
  # GET /movies.json
  def index
    @filter = params[:filter]
    case @filter
    when 'downvoted'
      @movies = Movie.joins(:votes).where(votes: { user: current_user, status: :down })
    when 'upvoted'
      @movies = Movie.joins(:votes).where(votes: { user: current_user, status: :up })
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
