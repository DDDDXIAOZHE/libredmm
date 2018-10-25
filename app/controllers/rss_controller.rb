require 'open-uri'

class RssController < ApplicationController
  # GET /users/foo@bar.com/pipe.rss
  def pipe
    @user = User.find_by_email! params[:user_email]
    xml = Nokogiri::XML URI.parse(params[:src]).open
    xml.xpath('//channel/item').each do |item|
      title = item.xpath('./title').text
      begin
        movie = Movie.search!(title)
        item.remove if Vote.where(user: @user, movie: movie).exists?
      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
        logger.error e.message
      end
    end
    render xml: xml
  end

  # GET /users/foo@bar.com/torrents.rss
  def torrents
    @user = User.find_by_email!(params[:user_email])
    @torrents = Resource.in_bt.not_voted_by(@user).order(
      created_at: :desc,
    ).limit(params.fetch(:limit, 20))
  end
end
