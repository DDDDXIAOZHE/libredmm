require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  test 'should reject duplicate code' do
    movie = create(:movie)
    assert_raise ActiveRecord::RecordInvalid do
      create(:movie, code: movie.code)
    end
  end

  test 'should reject empty code' do
    movie = create(:movie)
    assert_raise ActiveRecord::RecordInvalid do
      create(:movie, code: '')
    end
  end

  test 'should search details via api before create' do
    movie = create(:movie)
    assert_requested(@api_stub)
  end

  test 'should reject code with no search result' do
    @api_stub = stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(status: 404)
    assert_raise ActiveRecord::RecordNotFound do
      movie = create(:movie)
    end
  end
end
