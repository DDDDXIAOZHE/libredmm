require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should redirect search" do
    code = generate :code
    get search_url(q: code)
    assert_redirected_to movie_url(id: code)
  end
end
