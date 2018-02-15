require 'rails_helper'

RSpec.describe 'movies/show' do
  before(:each) do
    @movie = create(:movie)
  end

  it 'renders cover image and sample images in a carousel' do
    render
    expect(rendered).to have_selector('.carousel-item', count: @movie.sample_images.size + 1)
    expect(rendered).to have_selector('.carousel-item.active', count: 1)
  end

  context 'when signed in' do
    before(:each) do
      @user = create :user
      allow(view).to receive(:signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(@user)
    end

    context 'when voted' do
      before(:each) do
        create :vote, movie: @movie, user: @user
      end

      it 'renders one vote link and one unvote link' do
        render
        expect(rendered).to have_selector("a[href*='#{@movie.code}/vote'][data-method='put']", count: 1)
        expect(rendered).to have_selector("a[href*='#{@movie.code}/vote'][data-method='delete']", count: 1)
      end
    end

    context 'when not voted' do
      it 'renders two vote links' do
        render
        expect(rendered).to have_selector("a[href*='#{@movie.code}/vote'][data-method='put']", count: 2)
        expect(rendered).not_to have_selector("a[href*='#{@movie.code}/vote'][data-method='delete']")
      end
    end
  end

  context 'when not signed in' do
    it 'does not render vote links' do
      render
      expect(rendered).not_to have_selector("a[href*='#{@movie.code}/vote']")
    end
  end
end
