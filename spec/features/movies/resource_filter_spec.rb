require 'rails_helper'

RSpec.feature 'List movies with resource filter', type: :feature do
  before :each do
    @user = create :user
    @admin = create :user, is_admin: true
    2.times do
      create :movie
    end
    3.times do
      create :resource
    end
  end

  context 'empty' do
    scenario 'when signed out' do
      visit movies_url
      expect(page).to have_selector('.movie', count: Movie.count)
    end
  end

  context 'all' do
    scenario 'when signed out' do
      visit movies_url(resource: 'all')
      expect(page).to have_selector('.movie', count: Movie.count)
    end
  end

  context 'unknown' do
    scenario 'when signed out' do
      visit movies_url(resource: 'unknown')
      expect(page).to have_selector('.movie', count: Movie.count)
    end
  end

  context 'any' do
    scenario 'when signed in' do
      visit movies_url(resource: 'any', as: @user)
      expect(page).not_to have_selector('.movie')
    end

    scenario 'when signed in as admin' do
      visit movies_url(resource: 'any', as: @admin)
      expect(page).to have_selector('.movie', count: Movie.with_resources.count)
    end

    scenario 'when signed out' do
      visit movies_url(resource: 'any')
      expect(page).not_to have_selector('.movie')
    end

    scenario 'and chained after vote filter' do
      create(:vote, user: @admin, movie: Movie.with_resources.first, status: :up)
      create(:vote, user: @admin, movie: Movie.without_resources.first, status: :up)
      visit movies_url(resource: 'any', vote: 'up', as: @admin)
      expect(page).to have_selector('.movie', count: 1)
    end
  end

  context 'none' do
    scenario 'when signed in' do
      visit movies_url(resource: 'none', as: @user)
      expect(page).to have_selector('.movie', count: Movie.count)
    end

    scenario 'when signed in as admin' do
      visit movies_url(resource: 'none', as: @admin)
      expect(page).to have_selector('.movie', count: Movie.without_resources.count)
    end

    scenario 'when signed out' do
      visit movies_url(resource: 'none')
      expect(page).to have_selector('.movie', count: Movie.count)
    end
  end
end
