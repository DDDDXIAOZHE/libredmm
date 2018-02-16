class MoviesController < ApplicationController
  # GET /movies
  # GET /movies.json
  def index
    filter_by_vote
    filter_by_resource
    @movies = @movies.order(code: :asc).page(params[:page])
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    @movie = Movie.search!(params[:id])
    redirect_to id: @movie.code if @movie.code != params[:id]
  end

  private

  def filter_by_vote
    @vote = params[:vote]
    case @vote
    when 'down'
      @movies = signed_in? ? current_user.downvoted_movies : Movie.none
    when 'up'
      @movies = signed_in? ? current_user.upvoted_movies : Movie.none
    when 'none'
      @movies = signed_in? ? current_user.unvoted_movies : Movie.all
    else
      @movies = Movie.all
      @vote = 'all'
    end
  end

  def filter_by_resource
    @resource = params[:resource]
    case @resource
    when 'any'
      @movies = signed_in_as_admin? ? @movies.with_resources : Movie.none
    when 'none'
      @movies = signed_in_as_admin? ? @movies.without_resources : @movies
    else
      @resource = 'all'
    end
  end
end
