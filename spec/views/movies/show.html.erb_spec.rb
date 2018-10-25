require 'rails_helper'

RSpec.describe 'movies/show' do
  before :each do
    @movie = create(:movie)
    2.times do
      create(:resource, movie: @movie)
    end
    allow(view).to receive(:signed_in?).and_return(false)
    without_partial_double_verification do
      allow(view).to receive(:signed_in_as_admin?).and_return(false)
    end
  end

  it 'renders cover image and sample images in a carousel' do
    render
    expect(rendered).to have_selector(
      '.carousel-item', count: @movie.sample_images.size + 1
    )
    expect(rendered).to have_selector('.carousel-item.active', count: 1)
  end

  it 'includes movie info in title' do
    render template: 'movies/show', layout: 'layouts/application'
    expect(rendered).to have_title("#{@movie.code} #{@movie.title}")
  end

  context 'when signed in' do
    before :each do
      @user = create :user, is_admin: false
      allow(view).to receive(:signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(@user)
    end

    it 'hides refresh button' do
      render
      expect(rendered).not_to have_selector('#refresh')
    end

    it 'hides resources' do
      render
      expect(rendered).not_to have_selector('#resources')
    end

    context 'when voted' do
      before :each do
        create :vote, movie: @movie, user: @user
      end

      it 'renders two vote link and one unvote link' do
        render
        expect(rendered).to have_selector(
          "a[href*='#{@movie.code}/vote'][data-method='put']", count: 2
        )
        expect(rendered).to have_selector(
          "a[href*='#{@movie.code}/vote'][data-method='delete']", count: 1
        )
      end
    end

    context 'when not voted' do
      it 'renders three vote links' do
        render
        expect(rendered).to have_selector(
          "a[href*='#{@movie.code}/vote'][data-method='put']", count: 3
        )
        expect(rendered).not_to have_selector(
          "a[href*='#{@movie.code}/vote'][data-method='delete']",
        )
      end
    end
  end

  context 'when signed in as admin' do
    before :each do
      @admin = create :user, is_admin: true
      allow(view).to receive(:signed_in?).and_return(true)
      without_partial_double_verification do
        allow(view).to receive(:signed_in_as_admin?).and_return(true)
      end
      allow(view).to receive(:current_user).and_return(@admin)
    end

    it 'renders refresh button' do
      render
      expect(rendered).to have_selector('#refresh')
    end

    it 'renders resources' do
      render
      expect(rendered).to have_selector(
        '#resources tbody tr', count: @movie.resources.count
      )
    end

    it 'renders download links' do
      render
      expect(rendered).to have_selector(
        "#resources a[href*='#{resource_path(@movie.resources.first)}']",
      )
    end

    it 'renders mark obsolete links' do
      render
      expect(rendered).to have_selector(
        "#resources a[href*='#{resource_path(@movie.resources.first)}']"\
        "[data-method='delete']",
      )
    end

    context 'when movie has no resource' do
      it 'hides resources' do
        @movie = create(:movie)
        expect(rendered).not_to have_selector('#resources')
      end
    end
  end

  context 'when not signed in' do
    it 'hides refresh button' do
      render
      expect(rendered).not_to have_selector('#refresh')
    end

    it 'hides resources' do
      render
      expect(rendered).not_to have_selector('#resources')
    end

    it 'hides vote links' do
      render
      expect(rendered).not_to have_selector("a[href*='#{@movie.code}/vote']")
    end
  end
end
