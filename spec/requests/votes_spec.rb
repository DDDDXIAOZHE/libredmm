require 'rails_helper'

RSpec.describe 'Votes', type: :request do
  before(:each) do
    @movie = create :movie
    @user = create :user
  end

  context 'when vote does not exist' do
    describe 'PUT /movies/:movie_id/vote' do
      it 'creates vote' do
        expect {
          put movie_vote_url(@movie, as: @user), params: { vote: { status: :up } }
        }.to change {
          Vote.where(movie: @movie, user: @user).count
        }.by(1)
      end

      it 'rejects illegal vote status' do
        expect {
          put movie_vote_url(@movie, as: @user), params: { vote: { status: :foo } }
        }.not_to change {
          Vote.where(movie: @movie, user: @user).count
        }
      end

      it 'redirects back' do
        put(
          movie_vote_url(@movie, as: @user),
          params: { vote: { status: :up } },
          headers: { 'HTTP_REFERER' => movies_url },
        )
        expect(response).to redirect_to(movies_url)
      end

      it 'redirects to movie page as fallback' do
        put movie_vote_url(@movie, as: @user), params: { vote: { status: :up } }
        expect(response).to redirect_to(@movie)
      end
    end

    describe 'DELETE /movies/:movie_id/vote' do
      it 'does nothing' do
        expect {
          delete movie_vote_url(@movie, as: @user)
        }.not_to change {
          Vote.where(movie: @movie, user: @user).count
        }
      end

      it 'redirects back' do
        delete movie_vote_url(@movie, as: @user), headers: { 'HTTP_REFERER' => movies_url }
        expect(response).to redirect_to(movies_url)
      end

      it 'redirects to movie page as fallback' do
        delete movie_vote_url(@movie, as: @user)
        expect(response).to redirect_to(@movie)
      end
    end
  end

  context 'when vote exists' do
    before(:each) do
      @movie = create :movie
      @user = create :user
      create :vote, movie: @movie, user: @user, status: :up
    end

    describe 'PUT /movies/:movie_id/vote' do
      it 'update vote' do
        expect {
          put movie_vote_url(@movie, as: @user), params: { vote: { status: :down } }
        }.to change {
          Vote.find_by(movie: @movie, user: @user).status
        }
      end

      it 'rejects illegal vote status' do
        expect {
          put movie_vote_url(@movie, as: @user), params: { vote: { status: :foo } }
        }.not_to change {
          Vote.where(movie: @movie, user: @user).count
        }
      end

      it 'redirects back' do
        put(
          movie_vote_url(@movie, as: @user),
          params: { vote: { status: :up } },
          headers: { 'HTTP_REFERER' => movies_url },
        )
        expect(response).to redirect_to(movies_url)
      end

      it 'redirects to movie page as fallback' do
        put movie_vote_url(@movie, as: @user), params: { vote: { status: :up } }
        expect(response).to redirect_to(@movie)
      end
    end

    describe 'DELETE /movies/:movie_id/vote' do
      it 'deletes vote' do
        expect {
          delete movie_vote_url(@movie, as: @user)
        }.to change {
          Vote.where(movie: @movie, user: @user).count
        }.by(-1)
      end

      it 'redirects back' do
        delete movie_vote_url(@movie, as: @user), headers: { 'HTTP_REFERER' => movies_url }
        expect(response).to redirect_to(movies_url)
      end

      it 'redirects to movie page as fallback' do
        delete movie_vote_url(@movie, as: @user)
        expect(response).to redirect_to(@movie)
      end
    end
  end
end
