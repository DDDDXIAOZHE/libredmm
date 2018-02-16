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
    scenario 'with empty vote filter' do
      visit movies_url(as: @user)
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end

    scenario 'with all vote filter' do
      visit movies_url(vote: 'all', as: @user)
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end

    scenario 'with unknown vote filter' do
      visit movies_url(vote: 'unknown', as: @user)
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end

    scenario 'with up vote filter' do
      visit movies_url(vote: 'up', as: @user)
      expect(page).to have_selector('.card-body', count: @up_vote)
    end

    scenario 'with down vote filter' do
      visit movies_url(vote: 'down', as: @user)
      expect(page).to have_selector('.card-body', count: @down_vote)
    end

    scenario 'with none vote filter' do
      visit movies_url(vote: 'none', as: @user)
      expect(page).to have_selector('.card-body', count: @no_vote)
    end
  end

  context 'when signed out' do
    scenario 'with empty vote filter' do
      visit movies_url
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end

    scenario 'with up vote filter' do
      visit movies_url(vote: 'up')
      expect(page).not_to have_selector('.card-body')
    end

    scenario 'with none vote filter' do
      visit movies_url(vote: 'none')
      expect(page).to have_selector('.card-body', count: @no_vote + @up_vote + @down_vote)
    end
  end
end
