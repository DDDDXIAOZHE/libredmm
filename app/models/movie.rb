require 'open-uri'

class Movie < ApplicationRecord
  has_many :votes
  has_many :resources

  scope :with_resources, -> { joins(:resources) }
  scope :without_resources, -> { includes(:resources).where(resources: { id: nil }) }

  validates :code, :cover_image, :page, :title, presence: true
  validates :code, uniqueness: { case_sensitive: false }

  before_validation on: :create do
    begin
      open "http://api.libredmm.com/search?q=#{code}" do |f|
        JSON.parse(f.read).each do |k, v|
          write_attribute(k.underscore, v)
        end
      end
    rescue StandardError
      raise ActiveRecord::RecordNotFound
    end
  end

  paginates_per 20

  def self.search!(code)
    movie = where('code ILIKE ?', "%#{code}%").first
    return movie if movie
    movie = create(code: code)
    movie.changed? ? Movie.find_by!(code: movie.code) : movie
  end

  def to_param
    code
  end
end
