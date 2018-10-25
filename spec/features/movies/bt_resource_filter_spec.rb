require 'rails_helper'

RSpec.feature 'List movies with bt resource filter', type: :feature do
  before :each do
    @user = create :user
    @admin = create :user, is_admin: true
    2.times do
      create :movie
    end
    3.times do
      create :resource, download_uri: generate(:torrent_uri)
    end
  end

  context 'empty' do
    scenario 'when signed out' do
      visit movies_url
      expect(page).to have_selector('.movie', count: Movie.count)
    end
  end

  context 'any' do
    scenario 'when signed out' do
      visit movies_url(bt_resource: 'any')
      expect(page).to have_selector('.movie', count: Movie.count)
    end
  end

  context 'unknown' do
    scenario 'when signed out' do
      visit movies_url(bt_resource: 'unknown')
      expect(page).to have_selector('.movie', count: Movie.count)
    end
  end

  context 'with' do
    scenario 'when signed in' do
      visit movies_url(bt_resource: 'with', as: @user)
      expect(page).not_to have_selector('.movie')
    end

    scenario 'when signed in as admin' do
      visit movies_url(bt_resource: 'with', as: @admin)
      expect(page).to have_selector(
        '.movie',
        count: Movie.with_bt_resources.count,
      )
    end

    scenario 'when signed out' do
      visit movies_url(bt_resource: 'with')
      expect(page).not_to have_selector('.movie')
    end

    scenario 'and chained after vote filter' do
      create(
        :vote,
        user: @admin,
        movie: Movie.with_bt_resources.first,
        status: :up,
      )
      create(
        :vote,
        user: @admin,
        movie: Movie.without_bt_resources.first,
        status: :up,
      )
      visit movies_url(bt_resource: 'with', vote: 'up', as: @admin)
      expect(page).to have_selector('.movie', count: 1)
    end
  end

  context 'without' do
    scenario 'when signed in' do
      visit movies_url(bt_resource: 'without', as: @user)
      expect(page).not_to have_selector('.movie')
    end

    scenario 'when signed in as admin' do
      visit movies_url(bt_resource: 'without', as: @admin)
      expect(page).to have_selector(
        '.movie',
        count: Movie.without_bt_resources.count,
      )
    end

    scenario 'when signed out' do
      visit movies_url(bt_resource: 'without')
      expect(page).not_to have_selector('.movie')
    end

    scenario 'and chained after vote filter' do
      create(
        :vote,
        user: @admin,
        movie: Movie.with_bt_resources.first,
        status: :up,
      )
      create(
        :vote,
        user: @admin,
        movie: Movie.without_bt_resources.first,
        status: :up,
      )
      visit movies_url(bt_resource: 'without', vote: 'up', as: @admin)
      expect(page).to have_selector('.movie', count: 1)
    end
  end
end
