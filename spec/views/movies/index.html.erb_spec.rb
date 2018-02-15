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
    
    it 'renders filters' do
      @filter = 'all'
      render
      expect(rendered).to have_selector("a[href*='movies?filter=']", count: 3)
      expect(rendered).to have_selector("a[href*='movies?filter=all'][class*='active']", count: 1)
    end

    it 'renders current filter as active' do
      @filter = 'downvoted'
      render
      expect(rendered).to have_selector("a[href*='movies?filter=downvoted'][class*='active']", count: 1)
    end
  end

  context 'when signed out' do
    it 'hides filters' do
      render
      expect(rendered).to have_selector("a[href*='movies?filter=']", count: 0)
    end
  end
end
