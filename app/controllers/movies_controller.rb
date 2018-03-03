class MoviesController < ApplicationController
  # GET /movies
  # GET /movies.json
  def index
    @movies = params[:fuzzy] ? Movie.fuzzy_match(params[:fuzzy]) : Movie.all
    filter_by_vote
    filter_by_resource
    order_and_paginate
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
      @movies = @movies.includes(:votes) if signed_in?
      @vote = 'all'
    end
  end

  def filter_by_resource
    @resource = params[:resource]
    case @resource
    when 'any'
      @movies = signed_in_as_admin? ? @movies.with_resources : Movie.none
    when 'baidu'
      @movies = signed_in_as_admin? ? @movies.with_baidu_pan_resources : Movie.none
    when 'bt'
      @movies = signed_in_as_admin? ? @movies.with_bt_resources : Movie.none
    when 'none'
      @movies = signed_in_as_admin? ? @movies.without_resources : @movies
    else
      @resource = 'all'
    end
  end

  def order_and_paginate
    @order = params[:order]
    case @order
    when 'latest'
      @movies = @movies.order(created_at: :desc)
    else
      @movies = @movies.order(code: :asc)
      @order = 'default'
    end
    @movies = @movies.page(params[:page])
  end
end
