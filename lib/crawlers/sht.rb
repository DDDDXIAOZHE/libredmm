# frozen_string_literal: true

require 'crawlers/crawler'

class ShtCrawler < Crawler
  def crawl_subtitled(page:, backfill:)
    crawl_forum(
      @agent.get("https://www.sehuatang.org/forum-103-#{page}.html"),
      tag: '色花堂中字',
      backfill: backfill,
    )
  end

  def extract_thread_links_from_forum(page)
    page.links_with(
      text: /\S+/,
      href: /thread-\d+-1-\d+\.html/,
      css: 'th a',
    )
  end

  def extract_title_from_thread(page)
    page.link_with!(text: /.+\.torrent/).to_s.gsub(' ', '')
  end

  def extract_dl_link_from_thread(page)
    page.link_with!(text: /.+\.torrent/)
  end
end
