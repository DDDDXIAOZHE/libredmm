require 'rails_helper'

RSpec.describe Movie, type: :model do
  context 'searching code in db' do
    before :each do
      @movie = create :movie
    end
    it 'returns existing movie' do
      expect(Movie.search!(@movie.code)).to eq(@movie)
    end

    it 'ignore cases' do
      expect(Movie.search!(@movie.code.downcase)).to eq(@movie)
      expect(Movie.search!(@movie.code.upcase)).to eq(@movie)
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

    it 'searches details via api' do
      Movie.search!(generate(:code))
      expect(@api_stub).to have_been_requested
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

    context 'when api returns non-ok code' do
      it 'raises RecordNotFound' do
        stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(status: 404)
        expect {
          Movie.search!(generate(:code))
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when api returns invalid attrs' do
      it 'raises RecordNotFound' do
        stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(
          body: lambda { |_|
            {
              Code: '',
            }.to_json
          },
        )
        expect {
          Movie.search!(generate(:code))
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'creating' do
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

    it 'requires a cover image' do
      expect {
        create(:movie, cover_image: '')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires a page' do
      expect {
        create(:movie, page: '')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires a title' do
      expect {
        create(:movie, title: '')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'has scope' do
    it 'with_resources' do
      create :movie
      resource = create :resource
      expect(Movie.with_resources.all).to eq([resource.movie])
    end

    it 'without_resources' do
      create :resource
      movie = create :movie
      expect(Movie.without_resources.all).to eq([movie])
    end
  end
end
