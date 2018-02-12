require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = create(:movie)
  end

  test 'should get index' do
    get movies_url
    assert_response :success
  end

  test 'should show movie' do
    get movie_url(@movie)
    assert_response :success
  end

  test 'should create movie on show' do
    @movie = build(:movie)
    assert_difference 'Movie.count' do
      get movie_url(@movie)
    end
  end

  test 'should redirect on show' do
    @api_stub = stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(
      body: lambda { |request|
        {
          Code: 'TEST' + request.uri.query_values['q'],
          CoverImage: 'https://dummyimage.com/800',
          Page: 'https://dummyimage.com/',
          Title: 'Dummy Movie',
        }.to_json
      },
    )
    @movie = build(:movie)
    get movie_url(@movie)
    assert_redirected_to id: 'TEST' + @movie.code
  end
end
