require 'rails_helper'

RSpec.describe Movie, type: :model do
  context 'searching code in db' do
    it 'returns existing movie' do
      movie = create(:movie)
      expect(Movie.search!(movie.code)).to eq(movie)
    end

    it 'ignore cases' do
      movie = create(:movie)
      expect(Movie.search!(movie.code.downcase)).to eq(movie)
    end
  end

  context 'searching code not in db' do
    it 'creates movie' do
      expect {
        Movie.search!(generate(:code))
      }.to change {
        Movie.count
      }.by(1)
    end

    context 'when api returns movie already in db' do
      it 'returns existing movie' do
        movie = create(:movie)
        stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(
          body: lambda { |_|
            {
              Code: movie.code,
              CoverImage: 'https://dummyimage.com/800',
              Page: 'https://dummyimage.com/',
              Title: 'Dummy Movie',
            }.to_json
          },
        )
        expect(Movie.search!(generate(:code))).to eq(movie)
      end
    end

    context 'when api returns nothing' do
      it 'raises RecordNotFound' do
        movie = create(:movie)
        stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(status: 404)
        expect {
          Movie.search!(generate(:code))
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'creating' do
    it 'searches details via api' do
      create(:movie)
      expect(@api_stub).to have_been_requested
    end

    it 'requires a code' do
      expect {
        create(:movie, code: '')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'rejects duplicate code' do
      movie = create(:movie)
      expect {
        create(:movie, code: movie.code)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'rejects duplicate code case insensitively' do
      movie = create(:movie)
      expect {
        create(:movie, code: movie.code.downcase)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'rejects code with invalid search result' do
      stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(
        body: lambda { |request|
          {
            Code: request.uri.query_values['q'],
          }.to_json
        },
      )
      expect {
        create(:movie)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'rejects code with no search result' do
      stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(status: 404)
      expect {
        create(:movie)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'with scopes' do
    it 'can do with_resources' do
      create :movie
      resource = create :resource
      expect(Movie.with_resources.all).to eq([resource.movie])
    end

    it 'can do without_resources' do
      create :resource
      movie = create :movie
      expect(Movie.without_resources.all).to eq([movie])
    end
  end
end
