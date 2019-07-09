# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'List codes with status filter', type: :feature do
  before :each do
    @user = create :user
    2.times do
      create :vote, user: @user, status: :up
    end
    3.times do
      create :vote, user: @user, status: :down
    end
    4.times do
      create :vote, user: @user, status: :bookmark
    end
  end

  scenario 'none' do
    visit user_vote_codes_url(@user.email)
    expect(page.text.split).to match_array(Movie.voted_by(@user).pluck(:code))
  end

  scenario 'up' do
    visit user_vote_codes_url(@user.email, status: :up)
    expect(page.text.split).to match_array(Movie.upvoted_by(@user).pluck(:code))
  end

  scenario 'down' do
    visit user_vote_codes_url(@user.email, status: :down)
    expect(page.text.split).to match_array(
      Movie.downvoted_by(@user).pluck(:code),
    )
  end

  scenario 'bookmark' do
    visit user_vote_codes_url(@user.email, status: :bookmark)
    expect(page.text.split).to match_array(
      Movie.bookmarked_by(@user).pluck(:code),
    )
  end
end
