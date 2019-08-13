# frozen_string_literal: true

require 'rails_helper'
require 'crawlers/thz'

RSpec.describe ThzCrawler, focus: true do
  let(:crawler) { ThzCrawler.new }

  before(:each) do
    stub_request(:get, %r{/forum-\d+-\d+.html}).to_return(
      File.new('spec/lib/crawlers/fixtures/thz.forum.html'),
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
      expect(crawler).to receive(:parse_thread).at_least(:once).and_raise(
        'Skipped in unit test',
      )
      crawler.crawl
    end

    it 'stops at current page if no new resource' do
      expect(crawler).to receive(:crawl_forum).once.and_call_original
      allow(crawler).to receive(:parse_thread).and_raise('Skipped in unit test')
      crawler.crawl
    end

    it 'uploads to s3' do
      thread_parsed = false
      allow(crawler).to receive(:parse_thread).and_wrap_original { |m, *args|
        raise 'Skipped in unit test' if thread_parsed

        m.call(*args)
        thread_parsed = true
      }
      expect(crawler).to receive(:upload_torrent).once.and_call_original
      crawler.crawl
    end

    it 'continues to next page if new resource found' do
      expect(crawler).to receive(:crawl_forum).twice.and_call_original
      thread_parsed = false
      allow(crawler).to receive(:parse_thread).and_wrap_original { |m, *args|
        raise 'Skipped in unit test' if thread_parsed

        m.call(*args)
        thread_parsed = true
      }
      crawler.crawl
    end
  end

  describe '.backfill' do
    it 'continues to next page even if no new resource found' do
      forum_crawled = false
      expect(crawler).to receive(:crawl_forum).twice.and_wrap_original { |m, *args|
        unless forum_crawled
          forum_crawled = true
          m.call(*args)
        end
      }
      allow(crawler).to receive(:parse_thread).and_raise('Skipped in unit test')
      crawler.backfill 1
    end
  end
end
