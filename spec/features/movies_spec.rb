require 'rails_helper'

RSpec.feature 'List movies', type: :feature do
  before(:each) do
    @user = create :user
    @no_vote = 2
    @no_vote.times do
      create :movie
    end
    @up_vote = 3
    @up_vote.times do
      movie = create :movie
      create :vote, user: @user, movie: movie, status: :up
    end
    @down_vote = 4
    @down_vote.times do
      movie = create :movie
      create :vote, user: @user, movie: movie, status: :down
    end
  end

  context 'when signed in' do
    scenario 'with empty filter' do
      visit movies_url(as: @user)
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end

    scenario 'with all filter' do
      visit movies_url(filter: 'all', as: @user)
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end

    scenario 'with unknown filter' do
      visit movies_url(filter: 'unknown', as: @user)
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end

    scenario 'with upvoted filter' do
      visit movies_url(filter: 'upvoted', as: @user)
      expect(page).to have_selector('.card-body', count: @up_vote)
    end

    scenario 'with downvoted filter' do
      visit movies_url(filter: 'downvoted', as: @user)
      expect(page).to have_selector('.card-body', count: @down_vote)
    end
  end

  context 'when signed out' do
    scenario 'with empty filter' do
      visit movies_url
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end

    scenario 'with upvoted filter' do
      visit movies_url(filter: 'upvoted')
      expect(page).to have_selector('.card-body', count: 0)
    end
  end
end
