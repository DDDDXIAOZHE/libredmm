# frozen_string_literal: true

require "rails_helper"

RSpec.describe Movie, type: :model do
  let(:movie) { create :movie }
  let(:vr_movie) { create :movie, title: "【VR】Dummy VR" }

  let(:user) { create :user }
  let(:bookmark) { create :vote, user: user, status: :bookmark }
  let(:upvote) { create :vote, user: user, status: :up }
  let(:downvote) { create :vote, user: user, status: :down }

  it "has resources" do
    resource = create :resource, movie: movie
    obsolete_resource = create :resource, movie: movie, is_obsolete: true
    expect(movie.resources).to include(resource)
    expect(movie.resources).not_to include(obsolete_resource)
  end

  it "has obsolete resources" do
    resource = create :resource, movie: movie
    obsolete_resource = create :resource, movie: movie, is_obsolete: true
    expect(movie.obsolete_resources).not_to include(resource)
    expect(movie.obsolete_resources).to include(obsolete_resource)
  end

  describe ".full_name" do
    it "contains code" do
      expect(movie.full_name).to include(movie.code)
    end

    it "contains title" do
      expect(movie.full_name).to include(movie.title)
    end
  end

  describe ".vr?" do
    it "returns true for VR movie" do
      expect(vr_movie).to be_vr
    end

    it "returns false for regular movie" do
      expect(movie).not_to be_vr
    end
  end

  describe ".normalize_code" do
    context "on short code" do
      it "does nothing" do
        unsaved_movie = build :movie, code: "CODE-020"
        expect {
          unsaved_movie.normalize_code
        }.not_to change {
          unsaved_movie.code
        }
      end
    end

    context "on long code without leading zero" do
      it "does nothing" do
        unsaved_movie = build :movie, code: "CODE-12345"
        expect {
          unsaved_movie.normalize_code
        }.not_to change {
          unsaved_movie.code
        }
      end
    end

    context "on long code with leading zero" do
      it "removes leading zero" do
        unsaved_movie = build :movie, code: "CODE-00123"
        expect {
          unsaved_movie.normalize_code
        }.to change {
          unsaved_movie.code
        }.to("CODE-123")
      end
    end

    context "on code with 3 leading digits" do
      it "removes 3 leading digits" do
        unsaved_movie = build :movie, code: "300CODE-90"
        expect {
          unsaved_movie.normalize_code
        }.to change {
          unsaved_movie.code
        }.to("CODE-90")
      end
    end
  end

  describe "#search" do
    context "for code in db" do
      it "returns existing movie" do
        expect(Movie.search!(movie.code)).to eq(movie)
      end

      it "ignores cases" do
        expect(Movie.search!(movie.code.downcase)).to eq(movie)
        expect(Movie.search!(movie.code.upcase)).to eq(movie)
      end

      it "allows paddings" do
        movie = create :movie, code: "CODE-123"
        expect(Movie.search!("[prefix]CODE-123-SUFFIX")).to eq(movie)
      end
    end

    context "for code not in db" do
      it "creates movie" do
        expect {
          Movie.search!(generate(:code))
        }.to change {
          Movie.count
        }.by(1)
      end

      it "searches details via api" do
        Movie.search!(generate(:code))
        expect(@api_stub).to have_been_requested
      end

      it "removes non-ascii characters when searching" do
        Movie.search!("敏abc感123词")
        expect(a_request(:get, "api.libredmm.com/search?q=abc%20123")).to(
          have_been_made,
        )
      end

      context "when api returns movie already in db" do
        it "returns existing movie" do
          stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
            body: ->(_) {
              {
                Code: movie.code,
                CoverImage: "https://dummyimage.com/800",
                Page: "https://dummyimage.com/",
                Title: "Dummy Movie",
              }.to_json
            },
          )
          expect(Movie.search!(generate(:code))).to eq(movie)
        end
      end

      context "when api returns non-ok code" do
        it "raises RecordNotFound" do
          stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
            status: 404,
          )
          expect {
            Movie.search!(generate(:code))
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when api returns invalid attrs" do
        it "raises RecordNotFound" do
          stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
            body: ->(_) {
              {
                Code: "",
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

  context "on create" do
    it "requires a code" do
      expect {
        create(:movie, code: "")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "rejects duplicate code" do
      expect {
        create(:movie, code: movie.code)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "rejects duplicate code case insensitively" do
      expect {
        create(:movie, code: movie.code.downcase)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "requires a cover image" do
      expect {
        create(:movie, cover_image: "")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "requires a page" do
      expect {
        create(:movie, page: "")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "requires a title" do
      expect {
        create(:movie, title: "")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "converts release date in string to date" do
      movie = create(:movie, release_date: "2018-03-01")
      expect(movie.release_date).to eq(Date.new(2018, 3, 1))
    end

    it "passes release date in date through" do
      date = Date.new(2012, 3, 4)
      movie = create(:movie, release_date: date)
      expect(movie.release_date).to eq(date)
    end
  end

  describe ".refresh" do
    it "searches details via api" do
      expect(@api_stub).not_to have_been_requested
      movie.refresh
      expect(@api_stub).to have_been_requested
    end

    context "when api returns valid attrs" do
      before :each do
        stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
          body: ->(_) {
            {
              Code: "ABC-123",
            }.to_json
          },
        )
      end

      it "return true attrs" do
        expect(movie.refresh).to be_truthy
      end

      it "update attrs" do
        expect {
          movie.refresh
        }.to change {
          movie.code
        }.to("ABC-123")
      end
    end

    context "when api returns non-ok code" do
      it "return false" do
        stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
          status: 404,
        )
        expect(movie.refresh).to be_falsey
      end
    end

    context "when api returns invalid attrs" do
      it "return false" do
        stub_request(:any, %r{api\.libredmm\.com/search\?q=}).to_return(
          body: ->(_) {
            {
              Code: "",
            }.to_json
          },
        )
        expect(movie.refresh).to be_falsey
      end
    end
  end

  context "scope" do
    describe "with_code" do
      it "ignores case" do
        expect(Movie.with_code(movie.code.downcase)).to include(movie)
      end
    end

    describe "with_resource_tag" do
      it "includes movies with resources with specific tag" do
        resource = create :resource, tags: ["TAG"]
        expect(Movie.with_resource_tag("TAG")).to include(resource.movie)
      end

      it "excludes movies with other resources" do
        resource = create :resource
        expect(Movie.with_resource_tag("TAG")).not_to include(resource.movie)
      end

      it "excludes movies with obsolete baidu pan resources" do
        resource = create :resource, tags: ["TAG"], is_obsolete: true
        expect(Movie.with_resource_tag("TAG")).not_to include(resource.movie)
      end

      it "excludes movies with obsolete baidu pan and valid other resource" do
        create(
          :resource,
          movie: movie,
          tags: ["TAG"],
          is_obsolete: true,
        )
        create :resource, movie: movie
        expect(Movie.with_resource_tag("TAG")).not_to include(movie)
      end

      it(
        "peforms better than naive intersection on already limited scope",
        benchmark: true,
      ) do
        100.times do
          movie = create :movie
          create :vote, movie: movie, user: user
          create :resource, movie: movie, tags: ["TAG"]
        end
        5000.times do
          create :resource, tags: ["TAG"]
        end
        s = Movie.voted_by(user)
        Benchmark.bm(10) do |bm|
          bm.report("joins") do
            s.joins(:resources).merge(Resource.valid.with_tag("TAG")).pluck(:id)
          end
          bm.report("intersect") do
            s.where(
              id: Resource.valid.with_tag("TAG").distinct.pluck(:movie_id),
            ).pluck(:id)
          end
        end
      end
    end

    describe "bookmarked_by, upvoted_by and downvoted_by" do
      it "works" do
        expect(Movie.bookmarked_by(user).all).to eq([bookmark.movie])
        expect(Movie.upvoted_by(user).all).to eq([upvote.movie])
        expect(Movie.downvoted_by(user).all).to eq([downvote.movie])
      end

      it "nil does not exist" do
        expect(Movie.bookmarked_by(nil)).not_to exist
        expect(Movie.upvoted_by(nil)).not_to exist
        expect(Movie.downvoted_by(nil)).not_to exist
        expect(Movie.voted_by(nil)).not_to exist
      end
    end

    describe "voted_by" do
      it "includes upvoted and downvoted movies" do
        expect(Movie.voted_by(user).all).to include(upvote.movie)
        expect(Movie.voted_by(user).all).to include(downvote.movie)
      end

      it "excludes bookmarked movies" do
        expect(Movie.voted_by(user).all).not_to include(bookmark.movie)
      end

      it "nil does not exist" do
        expect(Movie.voted_by(nil)).not_to exist
      end
    end

    describe "not_voted_by" do
      it "includes movies without votes" do
        expect(Movie.not_voted_by(user)).to include(movie)
      end

      it "excludes voted movies" do
        vote = create :vote, user: user
        expect(Movie.not_voted_by(user)).not_to include(vote.movie)
      end

      it "excludes bookmarked movies" do
        vote = create :vote, user: user, status: :bookmark
        expect(Movie.not_voted_by(user)).not_to include(vote.movie)
      end

      it "includes movies only voted by other" do
        vote = create :vote
        expect(Movie.not_voted_by(user)).to include(vote.movie)
      end

      it "excludes movies also voted by other" do
        create :vote, user: user, movie: movie
        create :vote, movie: movie
        expect(Movie.not_voted_by(user)).not_to include(movie)
      end

      it "nil includes movies without votes" do
        expect(Movie.not_voted_by(nil)).to include(movie)
      end

      it "nil includes voted movies" do
        vote = create :vote
        expect(Movie.not_voted_by(nil)).to include(vote.movie)
      end
    end

    describe "vr" do
      it "includes vr movies" do
        expect(Movie.vr.all).to include(vr_movie)
      end

      it "excludes regular movies" do
        expect(Movie.vr.all).not_to include(movie)
      end
    end

    describe "non_vr" do
      it "excludes vr movies" do
        expect(Movie.non_vr.all).not_to include(vr_movie)
      end

      it "includes regular movies" do
        expect(Movie.non_vr.all).to include(movie)
      end
    end

    describe "fuzzy_match" do
      it "matches actress" do
        movie = create :movie, actresses: ["ACTRESS STUB"]
        expect(Movie.fuzzy_match("actress")).to include(movie)
      end

      it "matches actress type" do
        movie = create :movie, actress_types: ["ACTRESS TYPE STUB"]
        expect(Movie.fuzzy_match("actress type")).to include(movie)
      end

      it "matches category" do
        movie = create :movie, categories: ["CATEGORY STUB"]
        expect(Movie.fuzzy_match("category")).to include(movie)
      end

      it "matches code" do
        movie = create :movie, code: "CODE-001"
        expect(Movie.fuzzy_match("code")).to include(movie)
      end

      it "matches director" do
        movie = create :movie, directors: ["DIRECTOR STUB"]
        expect(Movie.fuzzy_match("director")).to include(movie)
      end

      it "matches genre" do
        movie = create :movie, genres: ["GENRE STUB"]
        expect(Movie.fuzzy_match("genre")).to include(movie)
      end

      it "matches label" do
        movie = create :movie, genres: ["LABEL STUB"]
        expect(Movie.fuzzy_match("label")).to include(movie)
      end

      it "matches maker" do
        movie = create :movie, maker: "MAKER STUB"
        expect(Movie.fuzzy_match("maker")).to include(movie)
      end

      it "matches series" do
        movie = create :movie, series: "SERIES STUB"
        expect(Movie.fuzzy_match("series")).to include(movie)
      end

      it "matches tags" do
        movie = create :movie, tags: ["TAG STUB"]
        expect(Movie.fuzzy_match("tag")).to include(movie)
      end

      it "matches title" do
        movie = create :movie, title: "TITLE STUB"
        expect(Movie.fuzzy_match("title")).to include(movie)
      end
    end

    describe "latest_first" do
      it "orders by release_date desc first" do
        older = create :movie, release_date: "2017-01-01"
        later = create :movie, release_date: "2018-01-01"
        expect(Movie.latest_first.all).to eq([later, older])
      end

      it "orders by code asc next" do
        a = create :movie, code: "A-123", release_date: "2017-01-01"
        b = create :movie, code: "B-456", release_date: "2017-01-01"
        later = create :movie, release_date: "2018-01-01"
        expect(Movie.latest_first.all).to eq([later, a, b])
      end

      it "puts movie with null release_date at last" do
        nodate = create :movie
        older = create :movie, release_date: "2017-01-01"
        later = create :movie, release_date: "2018-01-01"
        expect(Movie.latest_first.all).to eq([later, older, nodate])
      end
    end

    describe "oldest_first" do
      it "orders by release_date desc first" do
        older = create :movie, release_date: "2017-01-01"
        later = create :movie, release_date: "2018-01-01"
        expect(Movie.oldest_first.all).to eq([older, later])
      end

      it "orders by code asc next" do
        a = create :movie, code: "A-123", release_date: "2017-01-01"
        b = create :movie, code: "B-456", release_date: "2017-01-01"
        later = create :movie, release_date: "2018-01-01"
        expect(Movie.oldest_first.all).to eq([a, b, later])
      end

      it "puts movie with null release_date at last" do
        nodate = create :movie
        older = create :movie, release_date: "2017-01-01"
        later = create :movie, release_date: "2018-01-01"
        expect(Movie.oldest_first.all).to eq([older, later, nodate])
      end
    end
  end
end
