class Resource < ApplicationRecord
  belongs_to :movie

  validates :movie_id, :download_uri, presence: true
  validates :download_uri, uniqueness: true
  validates :download_uri, format: { with: URI.regexp(%w[http https]) }
end
