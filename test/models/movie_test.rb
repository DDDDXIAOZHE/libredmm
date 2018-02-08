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
end
