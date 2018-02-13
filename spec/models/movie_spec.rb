require 'rails_helper'

RSpec.describe Movie, type: :model do
  it 'rejects duplicate code' do
    movie = create(:movie)
    expect {
      create(:movie, code: movie.code)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'rejects empty code' do
    expect {
      create(:movie, code: '')
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'searches details via api before create' do
    create(:movie)
    expect(@api_stub).to have_been_requested
  end

  it 'rejects code with no search result' do
    stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(status: 404)
    expect {
      create(:movie)
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
