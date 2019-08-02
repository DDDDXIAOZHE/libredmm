# frozen_string_literal: true

require 'aws-sdk-s3'
require 'mechanize'

class ThzCrawler
  def initialize
    @agent = Mechanize.new
    @s3 = AwsS3.new
  end

  def crawl
    crawl_forum(
      @agent.get('http://taohuazu.cc/forum-220-1.html'),
      backfill: false,
    )
  end

  def backfill(start_index)
    crawl_forum(
      @agent.get("http://taohuazu.cc/forum-220-#{start_index}.html"),
      backfill: true,
    )
  end

  def crawl_forum(page, backfill:)
    puts "=== #{page.uri} ===" unless Rails.env.test?
    found_new_resource = false
    page.links_with(
      text: /\S+/,
      href: /thread-\d+-1-\d+\.html/,
      css: 'th a',
    ).each do |thread_link|
      next if Resource.where(
        'source_uri LIKE ?',
        "%#{thread_link.href}",
      ).exists?

      parse_thread(thread_link)
      found_new_resource = true
    rescue StandardError => e
      warn " x #{e}: #{thread_link}" unless Rails.env.test?
    end
    return unless found_new_resource || backfill

    next_page_link = page.link_with(text: /下一页/)
    crawl_forum(next_page_link.click, backfill: backfill) if next_page_link
  end

  def parse_thread(link)
    page = link.click
    puts "# #{page.uri} #{link}" unless Rails.env.test?
    torrent_link = page.link_with!(text: /.+\.torrent/)
    movie = Movie.search! torrent_link.to_s
    download_link = torrent_link.click.link_with!(
      href: /forum.php\?mod=attachment&aid=.+/,
    )
    s3_url = @s3.put_torrent("thz/#{torrent_link}", download_link)
    resource = movie.resources.create!(
      download_uri: s3_url,
      source_uri: page.uri.to_s,
    )
    puts " ✓ #{movie.code} #{movie.title} <- #{resource.download_uri}" unless Rails.env.test?
  end
end
