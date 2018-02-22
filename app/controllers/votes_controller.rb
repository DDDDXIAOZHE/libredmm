class VotesController < ApplicationController
  before_action :require_login, only: %i[update destroy]
  before_action :set_movie_and_vote, only: %i[update destroy]
  protect_from_forgery except: :index

  # GET /users/foo@bar.com/vote.codes
  def index
    @user = User.find_by_email!(params[:user_email])
    respond_to do |format|
      format.codes { render plain: @user.voted_movies.map(&:code).sort.join("\n") }
      format.js { render :index }
    end
  end

  # PUT /movies/CODE-001/vote
  # PUT /movies/CODE-001/vote.json
  def update
    respond_to do |format|
      begin
        @vote.update_attributes(vote_params)
        format.html { redirect_back fallback_location: @movie, notice: "Voted #{@vote.status}!" }
        format.json { render :show, status: :ok, location: @movie }
      rescue ArgumentError, ActiveRecord::RecordInvalid
        format.html { redirect_back fallback_location: @movie, notice: 'Vote failed!' }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/CODE-001/vote
  # DELETE /movies/CODE-001/vote.json
  def destroy
    @vote.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: @movie, notice: 'Unvoted!' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_movie_and_vote
    @movie = Movie.search!(params[:movie_code])
    @vote = @movie.votes.find_or_initialize_by(user: current_user)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def vote_params
    params.require(:vote).permit(:status)
  end
end
