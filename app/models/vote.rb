class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :user, :movie, presence: true
  validates :user, uniqueness: { scope: :movie }

  enum status: [:up, :down]

  validates :status, presence: true
end
