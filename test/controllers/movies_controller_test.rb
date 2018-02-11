require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = create(:movie)
  end

  test "should get index" do
    get movies_url
    assert_response :success
  end

  test "should show movie" do
    get movie_url(@movie)
    assert_response :success
  end
end
