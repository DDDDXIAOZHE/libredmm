require 'rails_helper'

RSpec.feature 'List movies with vote filter', type: :feature do
  before(:each) do
    @user = create :user
    2.times do
      create :movie
    end
    3.times do
      create :vote, user: @user, status: :up
    end
    4.times do
      create :vote, user: @user, status: :down
    end
  end

  context 'empty' do
    scenario 'when signed out' do
      visit movies_url
      expect(page).to have_selector('.card-body', count: Movie.count)
    end
  end

  context 'all' do
    scenario 'when signed out' do
      visit movies_url(vote: 'all')
      expect(page).to have_selector('.card-body', count: Movie.count)
    end
  end

  context 'unknown' do
    scenario 'when signed out' do
      visit movies_url(vote: 'unknown')
      expect(page).to have_selector('.card-body', count: Movie.count)
    end
  end

  context 'up' do
    scenario 'when signed in' do
      visit movies_url(vote: 'up', as: @user)
      expect(page).to have_selector('.card-body', count: @user.upvoted_movies.count)
    end

    scenario 'when signed out' do
      visit movies_url(vote: 'up')
      expect(page).not_to have_selector('.card-body')
    end
  end

  context 'down' do
    scenario 'when signed in' do
      visit movies_url(vote: 'down', as: @user)
      expect(page).to have_selector('.card-body', count: @user.downvoted_movies.count)
    end

    scenario 'when signed out' do
      visit movies_url(vote: 'down')
      expect(page).not_to have_selector('.card-body')
    end
  end

  context 'none' do
    scenario 'when signed in' do
      visit movies_url(vote: 'none', as: @user)
      expect(page).to have_selector('.card-body', count: @user.unvoted_movies.count)
    end

    scenario 'when signed out' do
      visit movies_url(vote: 'none')
      expect(page).to have_selector('.card-body', count: Movie.count)
    end
  end
end
