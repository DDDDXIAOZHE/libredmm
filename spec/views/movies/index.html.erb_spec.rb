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
      allow(view).to receive(:signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(create(:user))
      @vote = 'up'
      controller.request.path_parameters['vote'] = 'up'
    end

    it 'renders vote filters' do
      render
      expect(rendered).to have_selector("nav#voteNav")
    end

    it 'renders current vote filter as active' do
      render
      expect(rendered).to have_selector("nav#voteNav a[class*='active']", count: 1)
      expect(rendered).to have_selector("nav#voteNav a[href*='vote=up'][class*='active']")
    end

    context 'as admin' do
      before(:each) do
        allow(view).to receive(:current_user).and_return(create(:user, is_admin: true))
        @resource = 'any'
        controller.request.path_parameters['resource'] = 'any'
      end

      it 'renders resource filters' do
        render
        expect(rendered).to have_selector("nav#resourceNav")
      end

      it 'renders current filters as active' do
        render
        expect(rendered).to have_selector("nav#voteNav a[class*='active']", count: 1)
        expect(rendered).to have_selector("nav#voteNav a[href*='vote=up'][class*='active']")
        expect(rendered).to have_selector("nav#resourceNav a[class*='active']", count: 1)
        expect(rendered).to have_selector("nav#resourceNav a[href*='resource=any'][class*='active']")
      end

      it 'renders links with combined filters' do
        render
        expect(rendered).to have_selector("nav#voteNav a[href*='resource=any']")
        expect(rendered).to have_selector("nav#resourceNav a[href*='vote=up']")
      end
    end

    context 'as non-admin' do
      it 'hides resource filters' do
        render
        expect(rendered).not_to have_selector("nav#resourceNav")
      end
    end
  end

  context 'when signed out' do
    it 'hides vote filters' do
      render
      expect(rendered).not_to have_selector("nav#voteNav")
    end

    it 'hides resource filters' do
      render
      expect(rendered).not_to have_selector("nav#resourceNav")
    end
  end
end
