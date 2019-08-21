# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Movies", type: :request do
  let(:movie) { create :movie }

  describe "GET /movies" do
    it "works" do
      get movies_url
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /movies/:code" do
    context "when movie exists" do
      it "renders movie" do
        get movie_url(movie)
        expect(response).to have_http_status(200)
      end
    end

    context "when movie does not exist" do
      it "creates movie" do
        expect {
          get movie_url(build(:movie))
        }.to change {
          Movie.count
        }.by(1)
      end

      it "redirects if new code is returned" do
        allow(Movie).to receive(:search!) { movie }
        get(movie_url(code: generate(:code)))
        expect(response).to redirect_to(code: movie.code)
      end

      it "redirects with request format preserved" do
        allow(Movie).to receive(:search!) { movie }
        get(movie_url(code: generate(:code), format: :json))
        expect(response).to redirect_to(code: movie.code, format: :json)
      end
    end
  end

  describe "DELETE /movies/:code" do
    context "when successfully refreshes" do
      it "redirects back to movie" do
        delete movie_url(movie)
        expect(response).to redirect_to(movie)
      end
    end

    context "when fails to refresh" do
      it "redirects back to movie" do
        stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
          status: 404,
        )
        delete movie_url(movie)
        expect(response).to redirect_to(movie)
      end

      it "returns on unprocessable_entity on failed json request" do
        stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
          status: 404,
        )
        delete movie_url(movie, format: :json)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
