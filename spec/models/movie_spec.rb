require 'rails_helper'

RSpec.describe Movie, type: :model do
  it 'has only non-obsolete resources' do
    movie = create :movie
    resource = create :resource, movie: movie
    create :resource, movie: movie, is_obsolete: true
    expect(movie.resources.all).to eq([resource])
  end

  context 'on destroy' do
    it 'destroys all votes' do
      vote = create :vote
      expect {
        vote.movie.destroy
      }.to change {
        Vote.count
      }.by(-1)
    end

    it 'destroys valid resources' do
      resource = create :resource
      expect {
        resource.movie.destroy
      }.to change {
        Resource.count
      }.by(-1)
    end

    it 'destroys obsolete resources as well' do
      resource = create :resource, is_obsolete: true
      expect {
        resource.movie.destroy
      }.to change {
        Resource.count
      }.by(-1)
    end
  end

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

    it 'removes non-ascii characters when searching' do
      Movie.search!('敏abc感123词')
      expect(a_request(:get, 'api.libredmm.com/search?q=abc%20123')).to have_been_made
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

    it 'converts release date in string to date' do
      movie = create(:movie, release_date: '2018-03-01')
      expect(movie.release_date).to eq(Date.new(2018, 3, 1))
    end

    it 'passes release date in date through' do
      date = Date.new(2012, 3, 4)
      movie = create(:movie, release_date: date)
      expect(movie.release_date).to eq(date)
    end
  end

  context 'refreshing' do
    before :each do
      @movie = create :movie
    end

    it 'searches details via api' do
      expect(@api_stub).not_to have_been_requested
      @movie.refresh
      expect(@api_stub).to have_been_requested
    end

    context 'when api returns valid attrs' do
      before :each do
        stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(
          body: lambda { |_|
            {
              Code: 'ABC-123',
            }.to_json
          },
        )
      end

      it 'return true attrs' do
        expect(@movie.refresh).to be_truthy
      end

      it 'update attrs' do
        expect {
          @movie.refresh
        }.to change {
          @movie.code
        }.to('ABC-123')
      end
    end

    context 'when api returns invalid attrs' do
      it 'return false' do
        stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(
          body: lambda { |_|
            {
              Code: '',
            }.to_json
          },
        )
        expect(@movie.refresh).to be_falsey
      end
    end
  end

  context 'scope' do
    describe 'with_resources' do
      it 'includes movies with only valid resources' do
        resource = create :resource
        expect(Movie.with_resources).to include(resource.movie)
      end

      it 'includes movies with both valid and obsolete resources' do
        movie = create :movie
        create :resource, movie: movie
        create :resource, movie: movie, is_obsolete: true
        expect(Movie.with_resources).to include(movie)
      end

      it 'excludes movies with no resource' do
        movie = create :movie
        expect(Movie.with_resources).not_to include(movie)
      end

      it 'excludes movies with only obsolete resources' do
        obsolete_resource = create :resource, is_obsolete: true
        expect(Movie.with_resources).not_to include(obsolete_resource.movie)
      end
    end

    describe 'without_resources' do
      it 'includes movies with no resource' do
        movie = create :movie
        expect(Movie.without_resources).to include(movie)
      end

      it 'includes movies with only obsolete resources' do
        obsolete_resource = create :resource, is_obsolete: true
        expect(Movie.without_resources).to include(obsolete_resource.movie)
      end

      it 'excludes movies with only valid resources' do
        resource = create :resource
        expect(Movie.without_resources).not_to include(resource.movie)
      end

      it 'excludes movies with both valid and obsolete resources' do
        movie = create :movie
        create :resource, movie: movie
        create :resource, movie: movie, is_obsolete: true
        expect(Movie.without_resources).not_to include(movie)
      end
    end

    describe 'with_baidu_pan_resources' do
      before :each do
        @baidu_pan_uri = 'http://pan.baidu.com/s/xxx'
      end

      it 'matches pan.baidu.com' do
        baidu_pan_resource = create :resource, download_uri: @baidu_pan_uri
        create :movie
        create :resource
        expect(Movie.with_baidu_pan_resources.all).to eq([baidu_pan_resource.movie])
      end

      it 'ignores obsolete resources' do
        create :resource, download_uri: @baidu_pan_uri, is_obsolete: true
        expect(Movie.with_baidu_pan_resources.all).not_to exist
      end
    end

    describe 'with_bt_resources' do
      before :each do
        @torrent_uri = 'http://www.libredmm.com/xxx.torrent'
      end

      it 'matches .torrent' do
        bt_resource = create :resource, download_uri: @torrent_uri
        create :movie
        create :resource
        expect(Movie.with_bt_resources.all).to eq([bt_resource.movie])
      end

      it 'only matches .torrent at the end of uri' do
        bt_resource = create :resource, download_uri: @torrent_uri
        create :resource, download_uri: @torrent_uri + '/suffix'
        expect(Movie.with_bt_resources.all).to eq([bt_resource.movie])
      end

      it 'ignores obsolete resources' do
        create :resource, download_uri: @torrent_uri, is_obsolete: true
        expect(Movie.with_baidu_pan_resources.all).not_to exist
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

    describe 'latest_first' do
      it 'orders by release_date desc' do
        older = create :movie, release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.latest_first.all).to eq([later, older])
      end

      it 'puts movie with null release_date at last' do
        nodate = create :movie
        older = create :movie, release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.latest_first.all).to eq([later, older, nodate])
      end
    end

    describe 'oldest_first' do
      it 'orders by release_date desc' do
        older = create :movie, release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.oldest_first.all).to eq([older, later])
      end

      it 'puts movie with null release_date at last' do
        nodate = create :movie
        older = create :movie, release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.oldest_first.all).to eq([older, later, nodate])
      end
    end
  end
end
