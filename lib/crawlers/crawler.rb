# frozen_string_literal: true

require 'aws-sdk-s3'
require 'mechanize'

class Crawler
  def initialize
    @agent = Mechanize.new

    Aws.config.update(
      credentials: Aws::Credentials.new(
        ENV['AWS_ACCESS_KEY_ID'],
        ENV['AWS_SECRET_ACCESS_KEY'],
      ),
    )
    @s3_bucket = Aws::S3::Resource.new(
      region: 'us-west-1',
      stub_responses: Rails.env.test?,
    ).bucket(ENV['AWS_S3_BUCKET'])
  end

  def crawl_forum(page, tag:, backfill:)
    puts "=== #{page.uri} ===" unless Rails.env.test?
    return unless extract_thread_links_from_forum(page).map { |thread_link|
      parse_thread thread_link, tag: tag
    }.any? || backfill

    next_page_link = extract_next_page_link_from_forum(page)
    crawl_forum(next_page_link.click, tag: tag, backfill: backfill) if next_page_link
  end

  def extract_thread_links_from_forum(_page)
    # :nocov:
    raise NotImplementedError
    # :nocov:
  end

  def extract_next_page_link_from_forum(page)
    page.link_with(text: /下一页/, href: /forum/)
  end

  def parse_thread(link, tag:)
    resource = Resource.where('source_uri LIKE ?', "%#{link.href}").first
    if resource
      puts " o #{resource.movie.full_name} -- #{resource.download_uri}" unless Rails.env.test?
      return
    end

    page = link.click
    title = extract_title_from_thread page
    dl_link = extract_dl_link_from_thread page
    resource = Movie.search!(title).resources.create!(
      download_uri: upload_torrent("#{tag}/#{title}", dl_link),
      source_uri: page.uri.to_s,
      tags: [tag],
    )
    puts " ✓ #{resource.movie.full_name} <- #{resource.download_uri}" unless Rails.env.test?
    resource
  rescue StandardError => e
    warn " x #{e} :: #{link}" unless Rails.env.test?
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

  def upload_torrent(path, dl_link)
    object = @s3_bucket.object(path)
    object.put(
      body: dl_link.click.content,
      content_disposition: 'attachment',
      content_type: 'application/x-bittorrent',
      acl: 'public-read',
    ) unless object.exists?
    object.public_url
  end
end
