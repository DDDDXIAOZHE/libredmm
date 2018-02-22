require 'open-uri'

class RssController < ApplicationController
  def pipe
    @user = User.find_by_email!(params[:user_email])
    xml = Nokogiri::XML(open(params[:src]))
    xml.xpath('//channel/item').each do |item|
      title = item.xpath('./title').text
      movie = Movie.search!(title)
      item.remove if Vote.where(user: @user, movie: movie).exists?
    end
    render xml: xml
  end
end
