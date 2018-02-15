class VotesController < ApplicationController
  before_action :require_login
  before_action :set_movie_and_vote

  # PUT /movies/1/vote
  # PUT /movies/1/vote.json
  def update
    respond_to do |format|
      begin
        @vote.update_attributes(vote_params)
        format.html { redirect_to @movie, notice: "Voted #{@vote.status}!" }
        format.json { render :show, status: :ok, location: @movie }
      rescue ArgumentError, ActiveRecord::RecordInvalid
        format.html { redirect_to @movie, notice: 'Vote failed!' }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1/vote
  # DELETE /movies/1/vote.json
  def destroy
    @vote.destroy
    respond_to do |format|
      format.html { redirect_to @movie, notice: 'Unvoted!' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_movie_and_vote
    @movie = Movie.find_or_create_by!(code: params[:movie_id])
    @vote = @movie.votes.find_or_initialize_by(user: current_user)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def vote_params
    params.require(:vote).permit(:status)
  end
end
