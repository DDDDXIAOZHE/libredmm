require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  describe 'GET /movies' do
    it 'works' do
      get movies_url
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /movies/:id' do
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

      it 'redirects if new code is different' do
        stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(
          body: lambda { |request|
            {
              Code: 'TEST' + request.uri.query_values['q'],
              CoverImage: 'https://dummyimage.com/800',
              Page: 'https://dummyimage.com/',
              Title: 'Dummy Movie',
            }.to_json
          },
        )
        code = generate :code
        get(movie_url(id: code))
        expect(response).to redirect_to(id: 'TEST' + code)
      end
    end
  end
end
