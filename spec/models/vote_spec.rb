# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vote, type: :model do
  it 'rejects empty user' do
    expect {
      create(:vote, user: nil)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'rejects unsaved user' do
    expect {
      create(:vote, user: build(:user))
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'rejects empty movie' do
    expect {
      create(:vote, movie: nil)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'rejects unsaved movie' do
    expect {
      create(:vote, movie: build(:movie))
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

  it 'rejects invalid status' do
    expect {
      create(:vote, status: :invalid)
    }.to raise_error(ArgumentError)
  end
end
