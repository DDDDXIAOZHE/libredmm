class Movie < ApplicationRecord
  validates :code, presence: true
  validates :code, uniqueness: true
end
