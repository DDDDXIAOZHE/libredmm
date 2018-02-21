require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  describe 'GET /movies' do
    it 'works' do
      get movies_url
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /movies/:code' do
    context 'when movie exists' do
      it 'renders movie' do
        @movie = create(:movie)
        get movie_url(@movie)
        expect(response).to have_http_status(200)
      end
    end

    context 'when movie does not exist' do
      it 'creates movie' do
        expect {
          get movie_url(build(:movie))
        }.to change {
          Movie.count
        }.by(1)
      end

      it 'redirects if new code is returned' do
        movie = create :movie
        allow(Movie).to receive(:search!) { movie }
        get(movie_url(code: generate(:code)))
        expect(response).to redirect_to(code: movie.code)
      end
    end
  end
end
