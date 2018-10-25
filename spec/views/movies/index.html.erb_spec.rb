require 'rails_helper'

RSpec.describe 'movies/index' do
  before :each do
    5.times do
      create :movie
    end
    @movies = Movie.all.page(1)
  end

  context 'when signed in' do
    before :each do
      allow(view).to receive(:signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(create(:user))
      @vote = 'up'
      controller.request.path_parameters['vote'] = 'up'
    end

    it 'renders vote filters' do
      render
      expect(rendered).to have_selector('#voteNav')
    end

    it 'renders current vote filter as active' do
      render
      expect(rendered).to have_selector("#voteNav a[class*='active']", count: 1)
    end

    context 'as admin' do
      before :each do
        allow(view).to receive(:current_user).and_return(
          create(:user, is_admin: true),
        )
        @baidu_pan_resource = 'with'
        controller.request.path_parameters['baidu_pan_resource'] = 'with'
        @bt_resource = 'with'
        controller.request.path_parameters['bt_resource'] = 'with'
        @order = 'default'
        controller.request.path_parameters['order'] = 'default'
      end

      it 'renders resource filters' do
        render
        expect(rendered).to have_selector('#baiduPanResourceNav')
        expect(rendered).to have_selector('#btResourceNav')
      end

      it 'renders current filters as active' do
        render
        expect(rendered).to have_selector(
          "#voteNav a[class*='active']", count: 1
        )
        expect(rendered).to have_selector(
          "#baiduPanResourceNav a[class*='active']", count: 1
        )
        expect(rendered).to have_selector(
          "#btResourceNav a[class*='active']", count: 1
        )
      end

      it 'renders order options' do
        render
        expect(rendered).to have_selector('#orderNav')
      end

      it 'renders current order option as active' do
        render
        expect(rendered).to have_selector(
          "#orderNav a[class*='active']", count: 1
        )
      end

      it 'renders links with combined filters' do
        render
        expect(rendered).to have_selector(
          "#voteNav a[href*='bt_resource=with']",
        )
        expect(rendered).to have_selector("#voteNav a[href*='order=default']")
        expect(rendered).to have_selector(
          "#baiduPanResourceNav a[href*='order=default']",
        )
        expect(rendered).to have_selector(
          "#btResourceNav a[href*='order=default']",
        )
        expect(rendered).to have_selector("#orderNav a[href*='vote=up']")
      end
    end

    context 'as non-admin' do
      it 'hides resource filters' do
        render
        expect(rendered).not_to have_selector('#baiduPanResourceNav')
        expect(rendered).not_to have_selector('#btResourceNav')
      end
    end
  end

  context 'when signed out' do
    before :each do
    end

    it 'hides vote filters' do
      render
      expect(rendered).not_to have_selector('#voteNav')
    end

    it 'hides resource filters' do
      render
      expect(rendered).not_to have_selector('#baiduPanResourceNav')
      expect(rendered).not_to have_selector('#btResourceNav')
    end

    it 'hides order options' do
      render
      expect(rendered).not_to have_selector('#orderNav')
    end
  end
end
