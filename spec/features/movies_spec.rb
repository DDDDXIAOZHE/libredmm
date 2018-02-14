require 'rails_helper'

RSpec.feature 'List movies', type: :feature do
  before(:each) do
    @user = create :user
    2.times do
      movie = create :movie
    end
    3.times do
      movie = create :movie
      create :vote, user: @user, movie: movie, status: :up
    end
    4.times do
      movie = create :movie
      create :vote, user: @user, movie: movie, status: :down
    end
  end

  context 'when signed in' do
    scenario 'with empty filter' do
      visit movies_url(as: @user)
      expect(page).to have_selector(".card-body", count: 9)
    end

    scenario 'with all filter' do
      visit movies_url(filter: 'all', as: @user)
      expect(page).to have_selector(".card-body", count: 9)
    end

    scenario 'with unknown filter' do
      visit movies_url(filter: 'unknown', as: @user)
      expect(page).to have_selector(".card-body", count: 9)
    end

    scenario 'with upvoted filter' do
      visit movies_url(filter: 'upvoted', as: @user)
      expect(page).to have_selector(".card-body", count: 3)
    end

    scenario 'with downvoted filter' do
      visit movies_url(filter: 'downvoted', as: @user)
      expect(page).to have_selector(".card-body", count: 4)
    end
  end

  context 'when signed out' do
    scenario 'with empty filter' do
      visit movies_url
      expect(page).to have_selector(".card-body", count: 9)
    end

    scenario 'with upvoted filter' do
      visit movies_url(filter: 'upvoted')
      expect(page).to have_selector(".card-body", count: 0)
    end
  end
end
