# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Request user.js", type: :feature do
  let(:user) { create :user }

  it "works" do
    visit user_vote_user_js_url(user.email)
  end
end
