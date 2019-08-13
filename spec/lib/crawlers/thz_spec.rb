# frozen_string_literal: true

require 'rails_helper'
require 'crawlers/thz'
require 'uploaders/aws_s3'

RSpec.describe ThzCrawler do
  let(:crawler) { ThzCrawler.new }
  let(:s3) { instance_double('S3') }

  before(:each) do
    allow(s3).to receive(:put_torrent).and_return(
      'http://s3.aws.com/path/to.torrent',
    )
    allow(AwsS3).to receive(:new).and_return(s3)
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
      crawler.crawl
      expect(s3).to have_received(:put_torrent).once
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
