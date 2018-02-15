class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :user, :movie, presence: true
  validates :user, uniqueness: { scope: :movie }

  enum status: %i[up down]

  validates :status, presence: true
end
