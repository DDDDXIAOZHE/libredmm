require 'open-uri'

class Movie < ApplicationRecord
  validates :code, presence: true
  validates :code, uniqueness: true

  before_create do
    begin
      open "http://api.libredmm.com/search?q=#{self.code}" do |f|
        JSON.parse(f.read).each do |k, v|
          self.write_attribute(k.underscore, v)
        end
      end
    rescue
      raise ActiveRecord::RecordInvalid
    end
  end
end
