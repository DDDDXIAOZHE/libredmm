class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :user_id, :movie_id, presence: true
  validates :user, uniqueness: { scope: :movie }

  enum status: %i[up down bookmark]

  validates :status, presence: true
end
