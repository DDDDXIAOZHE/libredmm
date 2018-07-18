require 'open-uri'

class Movie < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :resources, -> { where(is_obsolete: false) }, dependent: :destroy
  has_many :obsolete_resources, -> { where(is_obsolete: true) }, dependent: :destroy, class_name: 'Resource'

  scope :with_resources, -> {
    joins(:resources).where(resources: { is_obsolete: false }).distinct
  }
  scope :with_baidu_pan_resources, -> {
    with_resources.where('resources.download_uri ILIKE ?', '%pan.baidu.com%')
  }
  scope :with_bt_resources, -> {
    with_resources.where('resources.download_uri ILIKE ?', '%.torrent')
  }
  scope :without_resources, -> {
    includes(:resources).where(resources: { id: nil }).or(
      includes(:resources).where(resources: { is_obsolete: true })
    )
  }

  scope :bookmarked_by, ->(user) {
    includes(:votes).where(votes: { user: user, status: :bookmark })
  }
  scope :upvoted_by, ->(user) {
    includes(:votes).where(votes: { user: user, status: :up })
  }
  scope :downvoted_by, ->(user) {
    includes(:votes).where(votes: { user: user, status: :down })
  }
  scope :voted_by, ->(user) {
    includes(:votes).where(votes: { user: user }).where.not(
      votes: { status: :bookmark }
    )
  }
  scope :not_voted_by, ->(user) {
    where.not(id: joins(:votes).where(votes: { user: user }))
  }

  scope :fuzzy_match, ->(keyword) {
    where('code ILIKE ?', "%#{keyword}%").or(
      where('label ILIKE ?', "%#{keyword}%")
    ).or(
      where('maker ILIKE ?', "%#{keyword}%")
    ).or(
      where('series ILIKE ?', "%#{keyword}%")
    ).or(
      where('title ILIKE ?', "%#{keyword}%")
    ).or(
      where("ARRAY_TO_STRING(actresses, ' ') ILIKE ?", "%#{keyword}%")
    ).or(
      where("ARRAY_TO_STRING(actress_types, ' ') ILIKE ?", "%#{keyword}%")
    ).or(
      where("ARRAY_TO_STRING(categories, ' ') ILIKE ?", "%#{keyword}%")
    ).or(
      where("ARRAY_TO_STRING(directors, ' ') ILIKE ?", "%#{keyword}%")
    ).or(
      where("ARRAY_TO_STRING(genres, ' ') ILIKE ?", "%#{keyword}%")
    ).or(
      where("ARRAY_TO_STRING(tags, ' ') ILIKE ?", "%#{keyword}%")
    )
  }

  scope :latest_first, -> { order('release_date DESC NULLS LAST') }
  scope :oldest_first, -> { order('release_date ASC NULLS LAST') }

  validates :code, :cover_image, :page, :title, presence: true
  validates :code, uniqueness: { case_sensitive: false }

  paginates_per 20

  def self.search!(code)
    code = code.gsub(/[^[:ascii:]]+/, ' ').strip
    movie = where('code ~* ?', "^\\d*#{code}$").first
    return movie if movie
    begin
      attrs = attrs_from_opendmm(code)
      return where('code ~* ?', "^\\d*#{attrs[:code]}$").first || create!(attrs)
    rescue StandardError
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.attrs_from_opendmm(code)
    open "http://api.libredmm.com/search?q=#{code}" do |f|
      return JSON.parse(f.read).map { |k, v|
        [k.underscore.to_sym, v]
      }.to_h
    end
  end

  def refresh
    update Movie.attrs_from_opendmm(code)
  rescue StandardError
    false
  end

  def release_date=(date)
    super(date.is_a?(String) ? Chronic.parse(date).try(:to_date) : date)
  end

  def full_name
    "#{code} #{title}"
  end

  def to_param
    code
  end

  def normalize_code!
    new_code = code.gsub(/^(\w+)-0*(\d{3,})/, '\1-\2')
    return if new_code == code
    dup = Movie.find_by(code: new_code)
    if dup
      merge_to!(dup)
    else
      update!(code: new_code)
    end
  end

  def merge_to!(movie)
    Vote.where(movie: self).update_all(movie_id: movie.id)
    Resource.where(movie: self).update_all(movie_id: movie.id)
    destroy!
  end
end
