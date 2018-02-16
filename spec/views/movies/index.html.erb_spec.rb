require 'rails_helper'

RSpec.describe 'movies/index' do
  before(:each) do
    5.times do
      create :movie
    end
    @movies = Movie.all.page(1)
  end

  context 'when signed in' do
    before(:each) do
      @user = create :user
      allow(view).to receive(:signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(@user)
    end

    it 'renders vote filters' do
      @vote = 'all'
      render
      expect(rendered).to have_selector("a[href*='movies?vote=']", count: 4)
      expect(rendered).to have_selector("a[href*='movies?vote=all'][class*='active']", count: 1)
    end

    it 'renders current vote filter as active' do
      @vote = 'down'
      render
      expect(rendered).to have_selector("a[href*='movies?vote=down'][class*='active']", count: 1)
    end
  end

  context 'when signed out' do
    it 'hides vote filters' do
      render
      expect(rendered).to have_selector("a[href*='movies?vote=']", count: 0)
    end
  end
end
