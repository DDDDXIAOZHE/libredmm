require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = movies(:one)
  end

  test "should get index" do
    get movies_url
    assert_response :success
  end

  test "should get new" do
    get new_movie_url
    assert_response :success
  end

  test "should create movie" do
    assert_difference('Movie.count') do
      post movies_url, params: { movie: { actress_types: @movie.actress_types, actresses: @movie.actresses, categories: @movie.categories, code: @movie.code, cover_image: @movie.cover_image, description: @movie.description, directors: @movie.directors, genres: @movie.genres, label: @movie.label, maker: @movie.maker, move_length: @movie.move_length, page: @movie.page, release_date: @movie.release_date, sample_images: @movie.sample_images, series: @movie.series, tags: @movie.tags, thumbnail_image: @movie.thumbnail_image, title: @movie.title } }
    end

    assert_redirected_to movie_url(Movie.last)
  end

  test "should show movie" do
    get movie_url(@movie)
    assert_response :success
  end

  test "should get edit" do
    get edit_movie_url(@movie)
    assert_response :success
  end

  test "should update movie" do
    patch movie_url(@movie), params: { movie: { actress_types: @movie.actress_types, actresses: @movie.actresses, categories: @movie.categories, code: @movie.code, cover_image: @movie.cover_image, description: @movie.description, directors: @movie.directors, genres: @movie.genres, label: @movie.label, maker: @movie.maker, move_length: @movie.move_length, page: @movie.page, release_date: @movie.release_date, sample_images: @movie.sample_images, series: @movie.series, tags: @movie.tags, thumbnail_image: @movie.thumbnail_image, title: @movie.title } }
    assert_redirected_to movie_url(@movie)
  end

  test "should destroy movie" do
    assert_difference('Movie.count', -1) do
      delete movie_url(@movie)
    end

    assert_redirected_to movies_url
  end
end
