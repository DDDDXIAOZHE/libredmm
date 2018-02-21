require 'rails_helper'

RSpec.describe 'Resources', type: :request do
  before(:each) do
    @resource = create :resource
    @user = create :user
  end

  context 'when signed out' do
    describe 'GET /resources/:resource_id' do
      it 'redirects to sign in page' do
        get resource_url(@resource)
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end

  context 'when signed in' do
    describe 'GET /resources/:resource_id' do
      it 'redirects to download uri' do
        get resource_url(@resource, as: @user)
        expect(response).to redirect_to(@resource.download_uri)
      end
    end

    context 'and not voted yet' do
      it 'bookmarks the movie' do
        expect {
          get resource_url(@resource, as: @user)
        }.to change {
          Vote.count
        }.by(1)
        expect(@resource.movie.votes.where(user: @user).first.status).to eq("bookmark")
      end
    end

    context 'and already voted' do
      before(:each) do
        create :vote, user: @user, movie: @resource.movie, status: :up
      end

      it 'does not vote again' do
        expect {
          get resource_url(@resource, as: @user)
        }.not_to change {
          @resource.movie.votes.where(user: @user).first
        }
      end
    end
  end
end
