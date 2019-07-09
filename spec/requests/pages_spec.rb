# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /search' do
    context 'when movie found' do
      it 'redirects to movie page' do
        code = generate :code
        get search_url(q: code)
        expect(response).to redirect_to(movie_url(code: code))
      end
    end

    context 'when movie not found' do
      it 'redirect_to fuzzy match page' do
        allow(Movie).to(
          receive(:search!).and_raise(ActiveRecord::RecordNotFound),
        )
        q = 'foo bar'
        get search_url(q: q)
        expect(response).to redirect_to(movies_url(fuzzy: q))
      end
    end
  end

  describe 'GET /' do
    it 'works' do
      get root_url
      expect(response).to have_http_status(200)
    end
  end
end
