# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'List movies with resource filter', type: :feature do
  before :each do
    @user = create :user
    @admin = create :user, is_admin: true
    2.times do
      create :movie
    end
    3.times do
      create :resource, tags: ['TAG']
    end
  end

  context 'empty' do
    scenario 'when signed out' do
      visit movies_url
      expect(page).to have_selector('.movie', count: Movie.count)
    end
  end

  context 'present' do
    scenario 'when signed in' do
      visit movies_url(resource: 'TAG', as: @user)
      expect(page).not_to have_selector('.movie')
    end

    scenario 'when signed in as admin' do
      visit movies_url(resource: 'TAG', as: @admin)
      expect(page).to have_selector(
        '.movie',
        count: Movie.with_resource_tag('TAG').count,
      )
    end

    scenario 'when signed out' do
      visit movies_url(resource: 'TAG')
      expect(page).not_to have_selector('.movie')
    end

    scenario 'and chained after vote filter' do
      create(
        :vote,
        user: @admin,
        movie: Movie.with_resource_tag('TAG').first,
        status: :up,
      )
      visit movies_url(resource: 'TAG', vote: 'up', as: @admin)
      expect(page).to have_selector('.movie', count: 1)
    end
  end
end
