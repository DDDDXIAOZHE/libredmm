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

  context 'on destroy' do
    it 'destroys all votes' do
      user = create :user
      %i[up down bookmark].each do |status|
        create :vote, user: user, status: status
      end
      expect {
        user.destroy
      }.to change {
        Vote.count
      }.by(-3)
    end
  end
end
