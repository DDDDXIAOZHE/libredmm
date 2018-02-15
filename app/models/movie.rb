require 'open-uri'

class Movie < ApplicationRecord
  has_many :votes

  validates :code, :cover_image, :page, :title, presence: true
  validates :code, uniqueness: true

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
    movie = find_or_create_by(code: code)
    movie.changed? ? Movie.find_by!(code: movie.code): movie
  end

  def to_param
    code
  end
end
