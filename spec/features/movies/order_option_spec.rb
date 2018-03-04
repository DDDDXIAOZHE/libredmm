require 'rails_helper'

RSpec.feature 'List movies with order option', type: :feature do
  before :each do
    2.times do
      create :movie
    end
  end

  scenario 'default' do
    visit movies_url
    expect(page).to have_selector('.movie', count: Movie.count)
  end

  scenario 'latest_resource' do
    visit movies_url(order: 'latest_resource')
    expect(page).to have_selector('.movie', count: Movie.count)
  end
end
