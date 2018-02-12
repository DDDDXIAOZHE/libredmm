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
        attributes_for(
          :movie,
          code: 'TEST' + request.uri.query_values['q'],
        ).map { |k ,v|
          [k.to_s.camelize, v]
        }.to_h.to_json
      },
    )
    @movie = build(:movie)
    get movie_url(@movie)
    assert_redirected_to id: 'TEST' + @movie.code
  end
end
