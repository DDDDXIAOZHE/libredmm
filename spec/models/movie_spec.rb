require 'rails_helper'

RSpec.describe Movie, type: :model do
  it 'has resources' do
    movie = create :movie
    resource = create :resource, movie: movie
    obsolete_resource = create :resource, movie: movie, is_obsolete: true
    expect(movie.resources).to include(resource)
    expect(movie.resources).not_to include(obsolete_resource)
  end

  it 'has obsolete resources' do
    movie = create :movie
    resource = create :resource, movie: movie
    obsolete_resource = create :resource, movie: movie, is_obsolete: true
    expect(movie.obsolete_resources).not_to include(resource)
    expect(movie.obsolete_resources).to include(obsolete_resource)
  end

  describe '.full_name' do
    it 'contains code' do
      movie = create :movie
      expect(movie.full_name).to include(movie.code)
    end

    it 'contains title' do
      movie = create :movie
      expect(movie.full_name).to include(movie.title)
    end
  end

  describe '.vr?' do
    it 'returns true for VR movie' do
      movie = create :movie, title: '【VR】Dummy VR'
      expect(movie.vr?).to be_truthy
    end

    it 'returns false for regular movie' do
      movie = create :movie
      expect(movie.vr?).to be_falsey
    end
  end

  describe '.normalize_code' do
    it 'changes code to upper case' do
      movie = build :movie, code: 'code-123'
      expect {
        movie.normalize_code
      }.to change {
        movie.code
      }.to('CODE-123')
    end

    context 'on short code' do
      it 'does nothing' do
        movie = build :movie, code: 'CODE-020'
        expect {
          movie.normalize_code
        }.not_to change {
          movie.code
        }
      end
    end

    context 'on long code without leading zero' do
      it 'does nothing' do
        movie = build :movie, code: 'CODE-12345'
        expect {
          movie.normalize_code
        }.not_to change {
          movie.code
        }
      end
    end

    context 'on long code with leading zero' do
      it 'removes leading zero' do
        movie = build :movie, code: 'CODE-00123'
        expect {
          movie.normalize_code
        }.to change {
          movie.code
        }.to('CODE-123')
      end
    end

    context 'on code with 3 leading digits' do
      it 'removes 3 leading digits' do
        movie = build :movie, code: '300CODE-90'
        expect {
          movie.normalize_code
        }.to change {
          movie.code
        }.to('CODE-90')
      end
    end
  end

  describe '#search' do
    context 'for code in db' do
      before :each do
        @movie = create :movie
      end

      it 'returns existing movie' do
        expect(Movie.search!(@movie.code)).to eq(@movie)
      end

      it 'ignores cases' do
        expect(Movie.search!(@movie.code.downcase)).to eq(@movie)
        expect(Movie.search!(@movie.code.upcase)).to eq(@movie)
      end

      it 'allows extra 3 digits at beginning' do
        movie = create :movie, code: '300MIUM-059'
        expect(Movie.search!('MIUM-059')).to eq(movie)
      end

      it 'does not allows extra single digit at beginning' do
        movie = create :movie, code: '3DSVR-020'
        expect(Movie.search!('DSVR-020')).not_to eq(movie)
      end

      it 'does not allows extra letters at beginning' do
        movie = create :movie, code: 'AMIUM-059'
        expect(Movie.search!('MIUM-059')).not_to eq(movie)
      end

      it 'does not allow extra digits at end' do
        movie = create :movie, code: 'LIBRE-1000'
        expect(Movie.search!('LIBRE-100')).not_to eq(movie)
      end
    end

    context 'for code not in db' do
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
        expect(a_request(:get, 'api.libredmm.com/search?q=abc%20123')).to(
          have_been_made,
        )
      end

      context 'when api returns movie already in db' do
        it 'returns existing movie' do
          movie = create(:movie)
          stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
            body: ->(_) {
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
          stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
            status: 404,
          )
          expect {
            Movie.search!(generate(:code))
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when api returns invalid attrs' do
        it 'raises RecordNotFound' do
          stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
            body: ->(_) {
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
  end

  context 'on create' do
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

  describe '.refresh' do
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
        stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
          body: ->(_) {
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

    context 'when api returns non-ok code' do
      it 'return false' do
        stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
          status: 404,
        )
        expect(@movie.refresh).to be_falsey
      end
    end

    context 'when api returns invalid attrs' do
      it 'return false' do
        stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
          body: ->(_) {
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
    describe 'with_baidu_pan_resources' do
      it 'includes movies with resources from pan.baidu.com' do
        resource = create :resource, download_uri: generate(:baidu_pan_uri)
        expect(Movie.with_baidu_pan_resources).to include(resource.movie)
      end

      it 'excludes movies with other resources' do
        resource = create :resource
        expect(Movie.with_baidu_pan_resources).not_to include(resource.movie)
      end

      it 'excludes movies with obsolete baidu pan resources' do
        movie = create :movie
        create(
          :resource,
          movie: movie,
          download_uri: generate(:baidu_pan_uri),
          is_obsolete: true,
        )
        expect(Movie.with_baidu_pan_resources).not_to include(movie)
      end

      it 'excludes movies with obsolete baidu pan and valid other resource' do
        movie = create :movie
        create(
          :resource,
          movie: movie,
          download_uri: generate(:baidu_pan_uri),
          is_obsolete: true,
        )
        create :resource, movie: movie, download_uri: generate(:torrent_uri)
        expect(Movie.with_baidu_pan_resources).not_to include(movie)
      end

      it 'chains with with_bt_resources' do
        movie = create :movie
        create :resource, movie: movie, download_uri: generate(:baidu_pan_uri)
        create :resource, movie: movie, download_uri: generate(:torrent_uri)
        expect(Movie.with_baidu_pan_resources.with_bt_resources).to(
          include(movie),
        )
      end

      it(
        'peforms better than naive intersection on already limited scope',
        benchmark: true,
      ) do
        user = create :user
        100.times do
          movie = create :movie
          create :vote, movie: movie, user: user
          create :resource, movie: movie, download_uri: generate(:baidu_pan_uri)
        end
        5000.times do
          create :resource, download_uri: generate(:baidu_pan_uri)
        end
        s = Movie.voted_by(user)
        Benchmark.bm(10) do |bm|
          bm.report('joins') do
            s.joins(:resources).merge(Resource.valid.in_baidu_pan).pluck(:id)
          end
          bm.report('intersect') do
            s.where(
              id: Resource.valid.in_baidu_pan.distinct.pluck(:movie_id),
            ).pluck(:id)
          end
        end
      end
    end

    describe 'without_baidu_pan_resources' do
      it 'excludes movies with resources from pan.baidu.com' do
        movie = create :movie
        create :resource, movie: movie, download_uri: generate(:baidu_pan_uri)
        expect(Movie.without_baidu_pan_resources.without_bt_resources).not_to(
          include(movie),
        )
      end

      it 'excludes movies with resources from pan.baidu.com and others' do
        movie = create :movie
        create :resource, movie: movie, download_uri: generate(:baidu_pan_uri)
        create :resource, movie: movie
        expect(Movie.without_baidu_pan_resources.without_bt_resources).not_to(
          include(movie),
        )
      end

      it 'includes movies with only other resources' do
        resource = create :resource
        expect(Movie.without_baidu_pan_resources).to include(resource.movie)
      end

      it 'includes movies with no resource' do
        movie = create :movie
        expect(Movie.without_baidu_pan_resources).to include(movie)
      end

      it 'includes movies with obsolete baidu pan resources' do
        resource = create(
          :resource,
          download_uri: generate(:baidu_pan_uri),
          is_obsolete: true,
        )
        expect(Movie.without_baidu_pan_resources).to include(resource.movie)
      end
    end

    describe 'with_bt_resources' do
      it 'includes movies with resources with uri ends with .torrent' do
        resource = create :resource, download_uri: generate(:torrent_uri)
        expect(Movie.with_bt_resources).to include(resource.movie)
      end

      it 'excludes movies with resources with .torrent in the middle of uri' do
        resource = create :resource, download_uri: 'http://www.libredmm.com/torrent/xxx'
        expect(Movie.with_bt_resources).not_to include(resource.movie)
      end

      it 'excludes movies with other resources' do
        resource = create :resource
        expect(Movie.with_bt_resources).not_to include(resource.movie)
      end

      it 'excludes movies with obsolete bt resources' do
        movie = create :movie
        create(
          :resource,
          movie: movie,
          download_uri: generate(:torrent_uri),
          is_obsolete: true,
        )
        expect(Movie.with_bt_resources).not_to include(movie)
      end

      it 'excludes movies with obsolete bt and valid other resources' do
        movie = create :movie
        create(
          :resource,
          movie: movie,
          download_uri: generate(:torrent_uri),
          is_obsolete: true,
        )
        create :resource, movie: movie
        expect(Movie.with_bt_resources).not_to include(movie)
      end
    end

    describe 'without_bt_resources' do
      it 'excludes movies with resources with uri ends with .torrent' do
        movie = create :movie
        create :resource, movie: movie, download_uri: generate(:torrent_uri)
        expect(Movie.without_bt_resources.without_bt_resources).not_to(
          include(movie),
        )
      end

      it 'excludes movies with .torrent resources and others' do
        movie = create :movie
        create :resource, movie: movie, download_uri: generate(:torrent_uri)
        create :resource, movie: movie
        expect(Movie.without_bt_resources.without_bt_resources).not_to(
          include(movie),
        )
      end

      it 'includes movies with resources with .torrent in the middle of uri' do
        resource = create :resource, download_uri: 'http://www.libredmm.com/torrent/xxx'
        expect(Movie.without_bt_resources).to include(resource.movie)
      end

      it 'includes movies with other resources' do
        resource = create :resource
        expect(Movie.without_bt_resources).to include(resource.movie)
      end

      it 'includes movies with no resource' do
        movie = create :movie
        expect(Movie.without_bt_resources).to include(movie)
      end

      it 'includes movies with obsolete bt resources' do
        resource = create(
          :resource,
          download_uri: generate(:torrent_uri),
          is_obsolete: true,
        )
        expect(Movie.without_bt_resources).to include(resource.movie)
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

      it 'includes upvoted and downvoted movies' do
        expect(Movie.voted_by(@user).all).to include(@upvote.movie)
        expect(Movie.voted_by(@user).all).to include(@downvote.movie)
      end

      it 'excludes bookmarked movies' do
        expect(Movie.voted_by(@user).all).not_to include(@bookmark.movie)
      end

      it 'nil does not exist' do
        expect(Movie.voted_by(nil)).not_to exist
      end
    end

    describe 'not_voted_by' do
      it 'includes movies without votes' do
        user = create :user
        movie = create :movie
        expect(Movie.not_voted_by(user)).to include(movie)
      end

      it 'excludes voted movies' do
        user = create :user
        vote = create :vote, user: user
        expect(Movie.not_voted_by(user)).not_to include(vote.movie)
      end

      it 'excludes bookmarked movies' do
        user = create :user
        vote = create :vote, user: user, status: :bookmark
        expect(Movie.not_voted_by(user)).not_to include(vote.movie)
      end

      it 'includes movies only voted by other' do
        user = create :user
        vote = create :vote
        expect(Movie.not_voted_by(user)).to include(vote.movie)
      end

      it 'excludes movies also voted by other' do
        user = create :user
        movie = create :movie
        create :vote, user: user, movie: movie
        create :vote, movie: movie
        expect(Movie.not_voted_by(user)).not_to include(movie)
      end

      it 'nil includes movies without votes' do
        movie = create :movie
        expect(Movie.not_voted_by(nil)).to include(movie)
      end

      it 'nil includes voted movies' do
        vote = create :vote
        expect(Movie.not_voted_by(nil)).to include(vote.movie)
      end
    end

    describe 'vr' do
      before :each do
        @vr_movie = create :movie, title: '【VR】Dummy VR'
        @regular_movie = create :movie
      end

      it 'includes vr movies' do
        expect(Movie.vr.all).to include(@vr_movie)
      end

      it 'excludes regular movies' do
        expect(Movie.vr.all).not_to include(@regular_movie)
      end
    end

    describe 'non_vr' do
      before :each do
        @vr_movie = create :movie, title: '【VR】Dummy VR'
        @regular_movie = create :movie
      end

      it 'excludes vr movies' do
        expect(Movie.non_vr.all).not_to include(@vr_movie)
      end

      it 'includes regular movies' do
        expect(Movie.non_vr.all).to include(@regular_movie)
      end
    end

    describe 'fuzzy_match' do
      it 'matches actress' do
        movie = create :movie, actresses: ['ACTRESS STUB']
        expect(Movie.fuzzy_match('actress')).to include(movie)
      end

      it 'matches actress type' do
        movie = create :movie, actress_types: ['ACTRESS TYPE STUB']
        expect(Movie.fuzzy_match('actress type')).to include(movie)
      end

      it 'matches category' do
        movie = create :movie, categories: ['CATEGORY STUB']
        expect(Movie.fuzzy_match('category')).to include(movie)
      end

      it 'matches code' do
        movie = create :movie, code: 'CODE-001'
        expect(Movie.fuzzy_match('code')).to include(movie)
      end

      it 'matches director' do
        movie = create :movie, directors: ['DIRECTOR STUB']
        expect(Movie.fuzzy_match('director')).to include(movie)
      end

      it 'matches genre' do
        movie = create :movie, genres: ['GENRE STUB']
        expect(Movie.fuzzy_match('genre')).to include(movie)
      end

      it 'matches label' do
        movie = create :movie, genres: ['LABEL STUB']
        expect(Movie.fuzzy_match('label')).to include(movie)
      end

      it 'matches maker' do
        movie = create :movie, maker: 'MAKER STUB'
        expect(Movie.fuzzy_match('maker')).to include(movie)
      end

      it 'matches series' do
        movie = create :movie, series: 'SERIES STUB'
        expect(Movie.fuzzy_match('series')).to include(movie)
      end

      it 'matches tags' do
        movie = create :movie, tags: ['TAG STUB']
        expect(Movie.fuzzy_match('tag')).to include(movie)
      end

      it 'matches title' do
        movie = create :movie, title: 'TITLE STUB'
        expect(Movie.fuzzy_match('title')).to include(movie)
      end
    end

    describe 'latest_first' do
      it 'orders by release_date desc first' do
        older = create :movie, release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.latest_first.all).to eq([later, older])
      end

      it 'orders by code asc next' do
        a = create :movie, code: 'A-123', release_date: '2017-01-01'
        b = create :movie, code: 'B-456', release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.latest_first.all).to eq([later, a, b])
      end

      it 'puts movie with null release_date at last' do
        nodate = create :movie
        older = create :movie, release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.latest_first.all).to eq([later, older, nodate])
      end
    end

    describe 'oldest_first' do
      it 'orders by release_date desc first' do
        older = create :movie, release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.oldest_first.all).to eq([older, later])
      end

      it 'orders by code asc next' do
        a = create :movie, code: 'A-123', release_date: '2017-01-01'
        b = create :movie, code: 'B-456', release_date: '2017-01-01'
        later = create :movie, release_date: '2018-01-01'
        expect(Movie.oldest_first.all).to eq([a, b, later])
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
