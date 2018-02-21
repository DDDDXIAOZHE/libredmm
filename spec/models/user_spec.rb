require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has votes' do
    user = create :user
    2.times do
      create :vote, user: user, status: :up
    end
    3.times do
      create :vote, user: user, status: :bookmark
    end
    expect(user.votes.size).to eq(2)
  end

  it 'has voted movies' do
    vote = create :vote, status: :up
    expect(vote.user.voted_movies).to eq([vote.movie])
  end

  it 'has upvotes and downvotes' do
    user = create :user
    2.times do
      create :vote, user: user, status: :up
    end
    3.times do
      create :vote, user: user, status: :down
    end
    expect(user.votes.size).to eq(5)
    expect(user.upvotes.size).to eq(2)
    expect(user.downvotes.size).to eq(3)
  end

  it 'has upvoted movies and downvoted movies' do
    user = create :user
    upvote = create :vote, user: user, status: :up
    downvote = create :vote, user: user, status: :down
    expect(user.upvoted_movies).to eq([upvote.movie])
    expect(user.downvoted_movies).to eq([downvote.movie])
  end

  it 'has bookmarks' do
    user = create :user
    2.times do
      create :vote, user: user, status: :up
    end
    3.times do
      create :vote, user: user, status: :bookmark
    end
    expect(user.bookmarks.size).to eq(3)
  end

  it 'has bookmarked movies' do
    vote = create :vote, status: :bookmark
    expect(vote.user.bookmarked_movies).to eq([vote.movie])
  end

  it 'has unvoted movies' do
    users = [create(:user), create(:user)]
    movies = [create(:movie), create(:movie), create(:movie)]
    create :vote, user: users[0], movie: movies[0]
    create :vote, user: users[1], movie: movies[1]
    expect(users[0].unvoted_movies).to eq([movies[1], movies[2]])
    expect(users[1].unvoted_movies).to eq([movies[0], movies[2]])
  end

  it 'can have none unvoted movies' do
    user = create(:user)
    create :vote, user: user
    create :vote, user: user
    expect(user.unvoted_movies).to be_empty
  end
end
