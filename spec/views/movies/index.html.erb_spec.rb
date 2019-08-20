# frozen_string_literal: true

require "rails_helper"

RSpec.describe "movies/index" do
  before :each do
    5.times do |i|
      create :resource, tags: ["TAG_#{i}"]
    end
    @movies = Movie.all.page(1)
  end

  it "renders order options" do
    render
    expect(rendered).to have_selector("#orderNav")
  end

  it "renders vr options" do
    render
    expect(rendered).to have_selector("#vrNav")
  end

  context "when signed in" do
    before :each do
      allow(view).to receive(:signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(create(:user))
      @vote = "up"
      controller.request.path_parameters["vote"] = "up"
    end

    it "renders vote filters" do
      render
      expect(rendered).to have_selector("#voteNav")
    end

    it "renders current vote filter as active" do
      render
      expect(rendered).to have_selector("#voteNav a[class*='active']", count: 1)
    end

    context "as admin" do
      before :each do
        allow(view).to receive(:current_user).and_return(
          create(:user, is_admin: true),
        )
        @resource = "TAG_1"
        controller.request.path_parameters["resource"] = @resource
        @order = "default"
        controller.request.path_parameters["order"] = @order
      end

      it "renders resource filters" do
        render
        expect(rendered).to have_selector("#resourceNav")
      end

      it "renders current filters as active" do
        render
        expect(rendered).to have_selector(
          "#voteNav a[class*='active']", count: 1,
        )
        expect(rendered).to have_selector(
          "#resourceNav a[class*='active']", count: 1,
        )
      end

      it "renders current order option as active" do
        render
        expect(rendered).to have_selector(
          "#orderNav a[class*='active']", count: 1,
        )
      end

      it "renders links with combined filters" do
        render
        expect(rendered).to have_selector(
          "#voteNav a[href*='resource=TAG_1']",
        )
        expect(rendered).to have_selector("#voteNav a[href*='order=default']")
        expect(rendered).to have_selector(
          "#resourceNav a[href*='order=default']",
        )
        expect(rendered).to have_selector("#orderNav a[href*='vote=up']")
      end
    end

    context "as non-admin" do
      it "hides resource filters" do
        render
        expect(rendered).not_to have_selector("#resourceNav")
      end
    end
  end

  context "when signed out" do
    before :each do
    end

    it "hides vote filters" do
      render
      expect(rendered).not_to have_selector("#voteNav")
    end

    it "hides resource filters" do
      render
      expect(rendered).not_to have_selector("#resourceNav")
    end
  end
end
