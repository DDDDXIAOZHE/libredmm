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

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie = Movie.search!(params[:code])
    respond_to do |format|
      if @movie.refresh
        format.html do
          redirect_back fallback_location: @movie, notice: 'Refreshed!'
        end
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html do
          redirect_back fallback_location: @movie, alert: 'Failed to refresh!'
        end
        format.json do
          render :show, status: :unprocessable_entity, location: @movie
        end
      end
    end
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
    end
  end

  def filter_by_resource
    filter_by_baidu_pan_resource
    filter_by_bt_resource
  end

  def filter_by_baidu_pan_resource
    @baidu_pan_resource = params[:baidu_pan_resource]
    case @baidu_pan_resource
    when 'with'
      @movies = signed_in_as_admin? ?
        @movies.with_baidu_pan_resources :
        Movie.none
    when 'without'
      @movies = signed_in_as_admin? ?
        @movies.without_baidu_pan_resources :
        Movie.none
    end
  end

  def filter_by_bt_resource
    @bt_resource = params[:bt_resource]
    case @bt_resource
    when 'with'
      @movies = signed_in_as_admin? ? @movies.with_bt_resources : Movie.none
    when 'without'
      @movies = signed_in_as_admin? ? @movies.without_bt_resources : Movie.none
    end
  end

  def order_and_paginate
    @order = params[:order]
    case @order
    when 'latest_first'
      @movies = @movies.latest_first
    when 'oldest_first'
      @movies = @movies.oldest_first
    else
      @movies = @movies.order(code: :asc)
      @order = 'default'
    end
    @movies = @movies.page(params[:page])
  end
end
