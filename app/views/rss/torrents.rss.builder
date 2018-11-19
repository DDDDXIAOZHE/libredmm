xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title "Unvoted torrents: #{@user.email}"
    xml.language 'zh-cn'
    xml.pubDate Time.now.utc.to_s(:rfc822)

    @torrents.each do |torrent|
      xml.item do
        xml.title torrent.movie.full_name.to_s
        xml.pubDate torrent.created_at.to_s(:rfc822)
        xml.guid File.basename(torrent.download_uri)
        xml.enclosure(
          type: 'application/x-bittorrent',
          url: torrent.download_uri,
        )
      end
    end
  end
end
