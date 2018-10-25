require 'rails_helper'

RSpec.describe 'Rss', type: :request do
  describe 'GET /users/:user_email/pipe.rss' do
    before :each do
      @user = create :user
      @movie = create :movie
      @feed = %(
        <rss>
          <channel>
            <title>Foobar</title>
            <item>
              <title>#{@movie.code}</title>
            </item>
            <item>
              <title>#{generate :code}</title>
            </item>
          </channel>
        </rss>
      )
      @feed_uri = 'http://foo.com/bar.rss'
      @feed_stub = stub_request(:any, %r{foo\.com/bar\.rss}).to_return(
        body: @feed,
      )
    end

    it 'works' do
      get "/users/#{@user.email}/pipe.rss?src=#{CGI.escape(@feed_uri)}"
      expect(response).to have_http_status(200)
    end

    it 'searches for movies' do
      expect {
        get "/users/#{@user.email}/pipe.rss?src=#{CGI.escape(@feed_uri)}"
      }.to change {
        Movie.count
      }
    end

    it 'works when movie not found' do
      stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
        status: 404,
      )
      get "/users/#{@user.email}/pipe.rss?src=#{CGI.escape(@feed_uri)}"
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /users/:user_email/torrents.rss' do
    before :each do
      @user = create :user
    end

    it 'works' do
      get "/users/#{@user.email}/torrents.rss"
      expect(response).to have_http_status(200)
    end
  end
end
