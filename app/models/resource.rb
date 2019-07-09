# frozen_string_literal: true

class Resource < ApplicationRecord
  belongs_to :movie

  validates :movie_id, :download_uri, presence: true
  validates :download_uri, uniqueness: true
  validates :download_uri, format: { with: URI.regexp(%w[http https]) }

  scope :in_baidu_pan, -> { where('download_uri ILIKE ?', '%pan.baidu.com%') }
  scope :in_bt, -> { where('download_uri ILIKE ?', '%.torrent') }
  scope :obsolete, -> { where(is_obsolete: true) }
  scope :valid, -> { where(is_obsolete: false) }

  scope :not_voted_by, ->(user) {
    where.not(id: joins(movie: :votes).where(movie: { votes: { user: user } }))
  }
end
