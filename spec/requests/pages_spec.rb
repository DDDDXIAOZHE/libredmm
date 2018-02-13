require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /search' do
    it 'redirects to movie#show' do
      code = generate :code
      expect(get(search_url(q: code))).to redirect_to(movie_url(id: code))
    end
  end
end
