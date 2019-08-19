# frozen_string_literal: true

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

  # GET /rss/torrents.rss
  def torrents
    @torrents = Resource.in_bt.order(created_at: :desc)
    @torrents = @torrents.with_tag(params[:tag]) if params[:tag]
    @torrents = @torrents.limit(params.fetch(:limit, 20))
  end
end
