require 'rails_helper'

RSpec.feature 'List movies with VR filter', type: :feature do
  before :each do
    2.times do
      create :movie, title: '【VR】Dummy VR'
    end
    3.times do
      create :movie
    end
  end

  scenario 'yes' do
    visit movies_url(vr: 'yes')
    expect(page).to have_selector('.movie', count: Movie.vr.count)
  end

  scenario 'no' do
    visit movies_url(vr: 'no')
    expect(page).to have_selector('.movie', count: Movie.non_vr.count)
  end

  scenario 'none' do
    visit movies_url
    expect(page).to have_selector('.movie', count: Movie.count)
  end
end
