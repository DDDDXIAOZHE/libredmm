require 'rails_helper'

RSpec.describe Vote, type: :model do
  it 'requires an user' do
    expect {
      create(:vote, user: nil)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'requires an movie' do
    expect {
      create(:vote, movie: nil)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'allows multiple votes per user' do
    vote = create :vote
    expect {
      create(:vote, user: vote.user)
    }.to change {
      vote.user.votes.count
    }.by(1)
  end

  it 'allows multiple votes per movie' do
    vote = create :vote
    expect {
      create(:vote, movie: vote.movie)
    }.to change {
      vote.movie.votes.count
    }.by(1)
  end

  it 'rejects votes with same user and movie' do
    vote = create :vote
    expect {
      create(:vote, user: vote.user, movie: vote.movie)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
