# frozen_string_literal: true

require 'rails_helper'
require 'crawlers/thz'

RSpec.describe ThzCrawler do
  let(:crawler) { ThzCrawler.new }

  before(:each) do
    stub_request(:get, %r{/forum-\d+-1.html}).to_return(
      File.new('spec/lib/crawlers/fixtures/thz.forum.first.trimmed.html'),
    )
    stub_request(:get, %r{/forum-\d+-2.html}).to_return(
      File.new('spec/lib/crawlers/fixtures/thz.forum.last.trimmed.html'),
    )
    stub_request(:get, %r{/thread-\d+-\d+-\d+.html}).to_return(
      File.new('spec/lib/crawlers/fixtures/thz.thread.html'),
    )
    stub_request(:get, %r{/imc_attachad-ad.html}).to_return(
      File.new('spec/lib/crawlers/fixtures/thz.attachment.html'),
    )
  end

  describe '.crawl' do
    it 'parses threads' do
      expect(crawler).to receive(:parse_thread).at_least(:once).and_return(nil)
      crawler.crawl
    end

    it 'uploads to s3' do
      expect(crawler).to receive(:upload_torrent).at_least(:once).and_return(nil)
      crawler.crawl
    end

    it 'stops at current page if no new resource' do
      expect(crawler).to receive(:crawl_forum).once.and_call_original
      allow(crawler).to receive(:parse_thread).and_return(nil)
      crawler.crawl
    end

    it 'continues to next page if new resource found' do
      expect(crawler).to receive(:crawl_forum).twice.and_call_original
      crawler.crawl
    end

    it 'stops at current page when repeatedly crawling' do
      crawler.crawl
      expect(crawler).to receive(:crawl_forum).once.and_call_original
      crawler.crawl
    end
  end

  describe '.backfill' do
    it 'continues to next page even if no new resource found' do
      expect(crawler).to receive(:crawl_forum).twice.and_call_original
      allow(crawler).to receive(:parse_thread).and_return(nil)
      crawler.backfill 1
    end
  end
end
