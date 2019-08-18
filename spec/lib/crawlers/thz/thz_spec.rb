# frozen_string_literal: true

require 'rails_helper'
require 'crawlers/thz'

RSpec.describe ThzCrawler do
  let(:crawler) { ThzCrawler.new }

  before(:each) do
    stub_request(:get, %r{/forum-\d+-1.html}).to_return(
      File.new('spec/lib/crawlers/thz/fixtures/forum.first.trimmed.html'),
    )
    stub_request(:get, %r{/forum-\d+-2.html}).to_return(
      File.new('spec/lib/crawlers/thz/fixtures/forum.last.trimmed.html'),
    )
    stub_request(:get, %r{/thread-\d+-\d+-\d+.html}).to_return(
      File.new('spec/lib/crawlers/thz/fixtures/thread.html'),
    )
    stub_request(:get, %r{/imc_attachad-ad.html}).to_return(
      File.new('spec/lib/crawlers/thz/fixtures/attachment.html'),
    )
  end

  describe '.crawl' do
    it 'crawls forum without backfilling' do
      expect(crawler).to receive(:crawl_forum).twice.with(
        anything, tag: '桃花族', backfill: false
      ).and_call_original
      crawler.crawl
    end

    it 'creates resources' do
      crawler.crawl
      expect(Resource.first).to have_attributes(
        source_uri: 'http://thz5.cc/thread-213795-1-1.html',
        download_uri: end_with('thz/%5BThZu.Cc%5Dofje-178.torrent'),
        tags: ['桃花族'],
      )
    end
  end

  describe '.backfill' do
    it 'crawls forum with backfilling' do
      expect(crawler).to receive(:crawl_forum).twice.with(
        anything, tag: '桃花族', backfill: true
      ).and_call_original
      crawler.backfill 1
    end
  end
end
