require 'rails_helper'

RSpec.describe 'pages/index' do
  it 'renders user email if signed in' do
    user = create :user
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)

    render template: 'pages/index', layout: 'layouts/application'

    expect(rendered).to match user.email
  end
end
