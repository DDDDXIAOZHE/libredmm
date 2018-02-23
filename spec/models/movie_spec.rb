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

    it 'requires exact match' do
      create :movie, code: 'LIBRE-1000'
      create :movie, code: 'LIBRE-100'
      expect(Movie.search!('LIBRE-100').code).to eq('LIBRE-100')
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

  context 'scope' do
    describe 'with_resources and without_resources' do
      it 'works' do
        resource = create :resource
        movie = create :movie
        expect(Movie.with_resources.all).to eq([resource.movie])
        expect(Movie.without_resources.all).to eq([movie])
      end
    end

    describe 'bookmarked_by, upvoted_by and downvoted_by' do
      before :each do
        @user = create :user
        @bookmark = create :vote, user: @user, status: :bookmark
        @upvote = create :vote, user: @user, status: :up
        @downvote = create :vote, user: @user, status: :down
      end

      it 'works' do
        expect(Movie.bookmarked_by(@user).all).to eq([@bookmark.movie])
        expect(Movie.upvoted_by(@user).all).to eq([@upvote.movie])
        expect(Movie.downvoted_by(@user).all).to eq([@downvote.movie])
      end

      it 'nil does not exist' do
        expect(Movie.bookmarked_by(nil)).not_to exist
        expect(Movie.upvoted_by(nil)).not_to exist
        expect(Movie.downvoted_by(nil)).not_to exist
        expect(Movie.voted_by(nil)).not_to exist
      end
    end

    describe 'voted_by' do
      before :each do
        @user = create :user
        @bookmark = create :vote, user: @user, status: :bookmark
        @upvote = create :vote, user: @user, status: :up
        @downvote = create :vote, user: @user, status: :down
      end

      it 'voted_by excludes bookmarks' do
        expect(Movie.voted_by(@user).all).to eq([@upvote.movie, @downvote.movie])
      end

      it 'nil does not exist' do
        expect(Movie.voted_by(nil)).not_to exist
      end
    end

    describe 'not_voted_by' do
      it 'includes movies without vote' do
        user = create :user
        movie = create :movie
        expect(Movie.not_voted_by(user).all).to eq([movie])
      end

      it 'includes movies only voted by other' do
        user = create :user
        vote = create :vote
        expect(Movie.not_voted_by(user).all).to eq([vote.movie])
      end

      it 'nil returns all movies' do
        expect(Movie.not_voted_by(nil).count).to eq(Movie.count)
      end
    end

    describe 'fuzzy_match' do
      it 'matches actress' do
        movie = create :movie, actresses: ['ACTRESS STUB']
        expect(Movie.fuzzy_match('actress').all).to eq([movie])
      end

      it 'matches actress type' do
        movie = create :movie, actress_types: ['ACTRESS TYPE STUB']
        expect(Movie.fuzzy_match('actress type').all).to eq([movie])
      end

      it 'matches category' do
        movie = create :movie, categories: ['CATEGORY STUB']
        expect(Movie.fuzzy_match('category').all).to eq([movie])
      end

      it 'matches code' do
        movie = create :movie, code: 'CODE-001'
        expect(Movie.fuzzy_match('code').all).to eq([movie])
      end

      it 'matches director' do
        movie = create :movie, directors: ['DIRECTOR STUB']
        expect(Movie.fuzzy_match('director').all).to eq([movie])
      end

      it 'matches genre' do
        movie = create :movie, genres: ['GENRE STUB']
        expect(Movie.fuzzy_match('genre').all).to eq([movie])
      end

      it 'matches label' do
        movie = create :movie, genres: ['LABEL STUB']
        expect(Movie.fuzzy_match('label').all).to eq([movie])
      end

      it 'matches maker' do
        movie = create :movie, maker: 'MAKER STUB'
        expect(Movie.fuzzy_match('maker').all).to eq([movie])
      end

      it 'matches series' do
        movie = create :movie, series: 'SERIES STUB'
        expect(Movie.fuzzy_match('series').all).to eq([movie])
      end

      it 'matches tags' do
        movie = create :movie, tags: ['TAG STUB']
        expect(Movie.fuzzy_match('tag').all).to eq([movie])
      end

      it 'matches title' do
        movie = create :movie, title: 'TITLE STUB'
        expect(Movie.fuzzy_match('title').all).to eq([movie])
      end
    end
  end
end
