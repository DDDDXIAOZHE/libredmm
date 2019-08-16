# frozen_string_literal: true

require 'crawlers/crawler'

class ThzCrawler < Crawler
  def crawl
    crawl_forum(
      @agent.get('http://taohuazu.cc/forum-220-1.html'),
      tag: '桃花族',
      backfill: false,
    )
  end

  def backfill(start_index)
    crawl_forum(
      @agent.get("http://taohuazu.cc/forum-220-#{start_index}.html"),
      tag: '桃花族',
      backfill: true,
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
    page.link_with!(text: /.+\.torrent/).to_s
  end

  def extract_dl_link_from_thread(page)
    page.link_with!(text: /.+\.torrent/).click.link_with!(
      href: /forum.php\?mod=attachment&aid=.+/,
    )
  end
end
