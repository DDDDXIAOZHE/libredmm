require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /search' do
    it 'redirects to movie#show' do
      code = generate :code
      get(search_url(q: code))
      expect(response).to redirect_to(movie_url(code: code))
    end

    it 'escapes param' do
      q = 'foo bar'
      get(search_url(q: q))
      expect(response).to redirect_to(movie_url(code: CGI.escape(q)))
    end
  end

  describe 'GET /' do
    it 'works' do
      get root_url
      expect(response).to have_http_status(200)
    end
  end
end
