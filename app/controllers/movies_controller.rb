class MoviesController < ApplicationController
  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
    filter_by_vote
    filter_by_resource
    @movies = @movies.includes(:votes) if signed_in?
    @movies = @movies.order(code: :asc).page(params[:page])
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    @movie = Movie.search!(params[:code])
    redirect_to code: @movie.code if @movie.code != params[:code]
  end

  private

  def filter_by_vote
    @vote = params[:vote]
    case @vote
    when 'up'
      @movies = @movies.upvoted_by(current_user)
    when 'down'
      @movies = @movies.downvoted_by(current_user)
    when 'bookmark'
      @movies = @movies.bookmarked_by(current_user)
    when 'none'
      @movies = @movies.not_voted_by(current_user)
    else
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
