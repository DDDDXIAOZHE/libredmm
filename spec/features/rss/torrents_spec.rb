# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Request unvoted torrents RSS', type: :feature do
  before :each do
    @user = create :user
    @baidu_pan_resource = create(
      :resource,
      download_uri: generate(:baidu_pan_uri),
    )
    @torrent_resource = create :resource, download_uri: generate(:torrent_uri)
  end

  scenario 'default' do
    visit user_torrents_url(user_email: @user.email)
    expect(page.body).to include(@torrent_resource.download_uri)
    expect(page.body).not_to include(@baidu_pan_resource.download_uri)
  end
end
