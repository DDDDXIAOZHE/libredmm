require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  describe 'GET /movies' do
    it 'works' do
      get movies_url
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /movies/:id' do
    it 'works' do
      @movie = create(:movie)
      get movie_url(@movie)
      expect(response).to have_http_status(200)
    end

    it 'create movie if possible' do
      expect {
        get movie_url(build(:movie))
      }.to change {
        Movie.count
      }.by(1)
    end

    it 'redirects if code changes after creating movie' do
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
