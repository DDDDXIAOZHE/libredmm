# frozen_string_literal: true

class VotesController < ApplicationController
  before_action :require_login, only: %i[update destroy]
  before_action :set_movie_and_vote, only: %i[update destroy]
  protect_from_forgery except: :index

  # GET /users/foo@bar.com/votes.codes
  def index
    @user = User.find_by_email!(params[:user_email])
    respond_to do |format|
      format.codes do
        movies = case params[:status]
                 when "up"
                   Movie.upvoted_by(@user)
                 when "down"
                   Movie.downvoted_by(@user)
                 when "bookmark"
                   Movie.bookmarked_by(@user)
                 else
                   Movie.voted_by(@user)
                 end
        render plain: movies.pluck(:code).sort.join("\n")
      end
      format.js { render :index }
    end
  end

  # PUT /movies/CODE-001/vote
  # PUT /movies/CODE-001/vote.json
  def update
    respond_to do |format|
      @vote.update_attributes(vote_params)
      format.html do
        redirect_back(
          fallback_location: @movie,
          notice: "Voted #{@vote.status}!",
        )
      end
      format.json { render :show, status: :ok, location: @movie }
    rescue ArgumentError, ActiveRecord::RecordInvalid
      format.html do
        redirect_back fallback_location: @movie, notice: "Vote failed!"
      end
      format.json { render json: @vote.errors, status: :unprocessable_entity }
    end
  end

  # DELETE /movies/CODE-001/vote
  # DELETE /movies/CODE-001/vote.json
  def destroy
    @vote.destroy
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @movie, notice: "Unvoted!"
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_movie_and_vote
    @movie = Movie.search!(params[:movie_code])
    @vote = @movie.votes.find_or_initialize_by(user: current_user)
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def vote_params
    params.require(:vote).permit(:status)
  end
end
