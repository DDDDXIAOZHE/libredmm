require 'mechanize'
require 'aws-sdk-s3'

class ThzCrawler
  def initialize
    @agent = Mechanize.new

    Aws.config.update(
      credentials: Aws::Credentials.new(
        ENV['AWS_ACCESS_KEY_ID'],
        ENV['AWS_SECRET_ACCESS_KEY'],
      ),
    )
    s3 = Aws::S3::Resource.new(region: 'us-west-1')
    @s3_bucket = s3.bucket ENV['AWS_S3_BUCKET']
  end

  def crawl
    crawl_forum @agent.get('http://thzvvv.com/forum-220-1.html'), backfill: false
  end

  def backfill(start_index)
    crawl_forum @agent.get("http://thzvvv.com/forum-220-#{start_index}.html"), backfill: true
  end

  def crawl_forum(page, backfill:)
    puts "=== #{page.uri} ==="
    found_new_resource = false
    page.links_with(text: /\S+/, href: /thread-\d+-1-\d+\.html/, css: 'th a').each do |thread_link|
      begin
        next if Resource.where('source_uri LIKE ?', "%#{thread_link.href}").exists?
        thread_page = thread_link.click
        puts "# #{thread_page.uri}"
        torrent_link = thread_page.link_with!(text: /.+\.torrent/)
        movie = Movie.search! torrent_link.to_s.gsub(/thz\.la/, '')
        download_link = torrent_link.click.link_with!(href: /forum.php\?mod=attachment&aid=.+/)
        s3_url = upload_to_s3(torrent_link.to_s, download_link)
        resource = movie.resources.create!(download_uri: s3_url, source_uri: thread_page.uri.to_s)
        found_new_resource = true
        puts " ✓ #{movie.code} #{movie.title} <- #{resource.download_uri}"
      rescue StandardError => e
        warn " x #{e}: #{thread_link}"
      end
    end
    if found_new_resource || backfill
      next_page_link = page.link_with(text: /下一页/)
      crawl_forum(next_page_link.click, backfill: backfill) if next_page_link
    end
  end

  def upload_to_s3(filename, dl_link)
    object = @s3_bucket.object("thz/#{filename}")
    object.put(
      body: dl_link.click.content,
      content_disposition: 'attachment',
      content_type: 'application/x-bittorrent',
      acl: 'public-read',
    ) unless object.exists?
    object.public_url
  end
end
