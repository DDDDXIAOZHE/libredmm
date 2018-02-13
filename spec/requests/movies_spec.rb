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
          attributes_for(
            :movie,
            code: 'TEST' + request.uri.query_values['q'],
          ).map { |k ,v|
            [k.to_s.camelize, v]
          }.to_h.to_json
        },
      )
      @movie = build(:movie)
      expect(get(movie_url(@movie))).to redirect_to(id: 'TEST' + @movie.code)
    end
  end
end
