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

  describe '.normalize_code!' do
    context 'on short code' do
      it 'does nothing' do
        movie = create :movie, code: "CODE-020"
        expect {
          movie.normalize_code!
        }.not_to change {
          movie.code
        }
      end
    end

    context 'on long code without leading zero' do
      it 'does nothing' do
        movie = create :movie, code: "CODE-12345"
        expect {
          movie.normalize_code!
        }.not_to change {
          movie.code
        }
      end
    end

    context 'on long code with leading zero' do
      it 'removes leading zero' do
        movie = create :movie, code: "CODE-00123"
        expect {
          movie.normalize_code!
        }.to change {
          movie.code
        }.to("CODE-123")
      end

      context 'on duplicate' do
        it 'merges movies' do
          movie = create :movie, code: "CODE-00123"
          dup = create :movie, code: "CODE-123"
          movie.normalize_code!
          expect(movie).to be_destroyed
        end
      end
    end
  end

  describe '.merge_to!' do
    it 'merges votes' do
      vote = create :vote
      new_movie = create :movie
      expect {
        vote.movie.merge_to!(new_movie)
      }.to change {
        vote.reload.movie
      }.to(new_movie)
    end

    it 'merges resources' do
      resource = create :resource
      new_movie = create :movie
      expect {
        resource.movie.merge_to!(new_movie)
      }.to change {
        resource.reload.movie
      }.to(new_movie)
    end

    it 'destroy itself' do
      movie = create :movie
      new_movie = create :movie
      movie.merge_to!(new_movie)
      expect(movie).to be_destroyed
    end
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

      it 'allows extra digits at beginning' do
        movie = create :movie, code: '300MIUM-059'
        expect(Movie.search!('MIUM-059')).to eq(movie)
      end

      it 'does not allows extra letters at beginning' do
        create :movie, code: 'AMIUM-059'
        movie = create :movie, code: '300MIUM-059'
        expect(Movie.search!('MIUM-059')).to eq(movie)
      end

      it 'does not allow extra digits at end' do
        create :movie, code: 'LIBRE-1000'
        movie = create :movie, code: 'LIBRE-100'
        expect(Movie.search!('LIBRE-100')).to eq(movie)
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

    context 'when api returns non-ok code' do
      it 'return false' do
        stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(status: 404)
        expect(@movie.refresh).to be_falsey
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

      it 'does not include duplicates' do
        movie = create :movie
        2.times do
          create :resource, movie: movie
        end
        expect(Movie.with_resources.count).to eq(1)
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

      it 'includes movies with resources from pan.baidu.com' do
        resource = create :resource, download_uri: @baidu_pan_uri
        expect(Movie.with_baidu_pan_resources).to include(resource.movie)
      end

      it 'excludes movies with other resources' do
        resource = create :resource
        expect(Movie.with_baidu_pan_resources).not_to include(resource.movie)
      end

      it 'ignores obsolete resources' do
        resource = create :resource, download_uri: @baidu_pan_uri, is_obsolete: true
        expect(Movie.with_baidu_pan_resources).not_to include(resource.movie)
      end
    end

    describe 'with_bt_resources' do
      before :each do
        @torrent_uri = 'http://www.libredmm.com/xxx.torrent'
      end

      it 'includes movies with resources with uri ends with .torrent' do
        resource = create :resource, download_uri: @torrent_uri
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

      it 'ignores obsolete resources' do
        resource = create :resource, download_uri: @torrent_uri, is_obsolete: true
        expect(Movie.with_bt_resources).not_to include(resource.movie)
      end
    end

    describe 'without_bt_resources' do
      before :each do
        @baidu_pan_uri = 'http://pan.baidu.com/s/xxx'
        @torrent_uri = 'http://www.libredmm.com/xxx.torrent'
      end

      it 'excludes movies with resources with uri ends with .torrent' do
        movie = create :movie
        create :resource, movie: movie, download_uri: @baidu_pan_uri
        create :resource, movie: movie, download_uri: @torrent_uri
        expect(Movie.with_baidu_pan_resources.without_bt_resources).not_to include(movie)
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

      it 'ignores obsolete resources' do
        resource = create :resource, download_uri: @torrent_uri, is_obsolete: true
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
