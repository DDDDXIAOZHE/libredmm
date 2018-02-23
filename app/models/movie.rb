require 'open-uri'

class Movie < ApplicationRecord
  has_many :votes
  has_many :resources

  scope :with_resources, -> { joins(:resources) }
  scope :without_resources, -> { includes(:resources).where(resources: { id: nil }) }

  scope :bookmarked_by, ->(user) { includes(:votes).where(votes: { user: user, status: :bookmark })}
  scope :upvoted_by, ->(user) { includes(:votes).where(votes: { user: user, status: :up })}
  scope :downvoted_by, ->(user) { includes(:votes).where(votes: { user: user, status: :down })}
  scope :voted_by, ->(user) { includes(:votes).where(votes: { user: user }).where.not(votes: { status: :bookmark })}
  scope :not_voted_by, ->(user) { includes(:votes).where.not(votes: { user: user }).or(includes(:votes).where(votes: { user: nil })) }

  validates :code, :cover_image, :page, :title, presence: true
  validates :code, uniqueness: { case_sensitive: false }

  paginates_per 20

  def self.search!(code)
    code = code.gsub(/[^[:ascii:]]/, '')
    movie = where('code ILIKE ?', "#{code}").first
    return movie if movie
    begin
      open "http://api.libredmm.com/search?q=#{code}" do |f|
        attrs = JSON.parse(f.read).map { |k, v|
          [k.underscore.to_sym, v]
        }.to_h
        movie = where('code ILIKE ?', "#{attrs[:code]}").first
        return movie ? movie : Movie.create!(attrs)
      end
    rescue StandardError
      raise ActiveRecord::RecordNotFound
    end
  end

  def to_param
    code
  end
end
