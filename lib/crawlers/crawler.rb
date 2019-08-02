# frozen_string_literal: true

require 'aws-sdk-s3'
require 'mechanize'

class Crawler
  def initialize
    @agent = Mechanize.new
    @s3 = AwsS3.new
  end

  def crawl_forum(page, backfill:)
    puts "=== #{page.uri} ===" unless Rails.env.test?
    found_new_resource = false
    extract_threads_from_forum(page).each do |thread_link|
      next if Resource.where(
        'source_uri LIKE ?',
        "%#{thread_link.href}",
      ).exists?

      parse_thread thread_link
      found_new_resource = true
    rescue StandardError => e
      warn " x #{e}: #{thread_link}" unless Rails.env.test?
    end
    return unless found_new_resource || backfill

    next_page_link = page.link_with(text: /下一页/)
    crawl_forum(next_page_link.click, backfill: backfill) if next_page_link
  end

  def extract_threads_from_forum(_page)
    # :nocov:
    raise NotImplementedError
    # :nocov:
  end

  def parse_thread(link)
    page = link.click
    title = extract_title_from_thread page
    movie = Movie.search! title
    download_link = extract_dl_link_from_thread page
    s3_url = @s3.put_torrent("thz/#{title}", download_link)
    resource = movie.resources.create!(
      download_uri: s3_url,
      source_uri: page.uri.to_s,
    )
    puts " ✓ #{movie.code} #{movie.title} <- #{resource.download_uri}" unless Rails.env.test?
  end

  def extract_title_from_thread(_page)
    # :nocov:
    raise NotImplementedError
    # :nocov:
  end

  def extract_dl_link_from_thread(_page)
    # :nocov:
    raise NotImplementedError
    # :nocov:
  end
end
