# frozen_string_literal: true

require 'rails_helper'
require 'crawlers/sht'

RSpec.describe ShtCrawler do
  let(:crawler) { ShtCrawler.new }

  describe '.crawl_subtitled' do
    before(:each) do
      stub_request(:get, %r{/forum-\d+-1.html}).to_return(
        File.new('spec/lib/crawlers/sht/fixtures/forum-103-1.trimmed.html'),
      )
      stub_request(:get, %r{/forum-\d+-2.html}).to_return(
        File.new('spec/lib/crawlers/sht/fixtures/forum-103-89.trimmed.html'),
      )
      stub_request(:get, %r{/thread-\d+-\d+-\d+.html}).to_return(
        File.new('spec/lib/crawlers/sht/fixtures/thread-156047-1-1.html'),
      )
    end

    it 'crawls forum' do
      expect(crawler).to receive(:crawl_forum).twice.with(
        anything, tag: '色花堂中字', backfill: false
      ).and_call_original
      crawler.crawl_subtitled page: 1, backfill: false
    end

    it 'creates resources' do
      crawler.crawl_subtitled page: 1, backfill: false
      expect(Resource.first).to have_attributes(
        source_uri: 'https://www.sehuatang.org/thread-156047-1-1.html',
        download_uri: end_with(
          "#{CGI.escape('色花堂中字')}/#{CGI.escape('IPZ-910-C.torrent')}",
        ),
        tags: ['色花堂中字'],
      )
    end
  end

  describe '.crawl_censored' do
    before(:each) do
      stub_request(:get, %r{/forum-\d+-1.html}).to_return(
        File.new('spec/lib/crawlers/sht/fixtures/forum-37-1.trimmed.html'),
      )
      stub_request(:get, %r{/forum-\d+-2.html}).to_return(
        File.new('spec/lib/crawlers/sht/fixtures/forum-37-380.trimmed.html'),
      )
      stub_request(:get, %r{/thread-\d+-\d+-\d+.html}).to_return(
        File.new('spec/lib/crawlers/sht/fixtures/thread-156592-1-1.html'),
      )
    end

    it 'crawls forum' do
      expect(crawler).to receive(:crawl_forum).twice.with(
        anything, tag: '色花堂', backfill: false
      ).and_call_original
      crawler.crawl_censored page: 1, backfill: false
    end

    it 'creates resources' do
      crawler.crawl_censored page: 1, backfill: false
      expect(Resource.first).to have_attributes(
        source_uri: 'https://www.sehuatang.org/thread-156592-1-1.html',
        download_uri: end_with(
          "#{CGI.escape('色花堂')}/#{CGI.escape('SIRO-3914.torrent')}",
        ),
        tags: ['色花堂'],
      )
    end
  end
end
