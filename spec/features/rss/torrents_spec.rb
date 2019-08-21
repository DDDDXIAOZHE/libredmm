# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Request torrents RSS", type: :feature do
  before :each do
  end

  scenario "without tag" do
    regular = create :resource
    torrent = create :resource, download_uri: generate(:torrent_uri)
    visit torrents_url
    expect(page.body).not_to include(regular.download_uri)
    expect(page.body).to include(torrent.download_uri)
  end

  scenario "with tag" do
    tag_a = create :resource, download_uri: generate(:torrent_uri), tags: ["a"]
    tag_b = create :resource, download_uri: generate(:torrent_uri), tags: ["b"]
    visit torrents_url(tag: "a")
    expect(page.body).to include(tag_a.download_uri)
    expect(page.body).not_to include(tag_b.download_uri)
  end
end
