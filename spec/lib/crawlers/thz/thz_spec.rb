# frozen_string_literal: true

require 'rails_helper'
require 'crawlers/thz'

RSpec.describe ThzCrawler do
  let(:crawler) { ThzCrawler.new }

  before(:each) do
    stub_request(:get, %r{/forum-\d+-1.html}).to_return(
      File.new('spec/lib/crawlers/thz/fixtures/forum-220-1.trimmed.html'),
    )
    stub_request(:get, %r{/forum-\d+-2.html}).to_return(
      File.new('spec/lib/crawlers/thz/fixtures/forum-220-517.trimmed.html'),
    )
    stub_request(:get, %r{/thread-\d+-\d+-\d+.html}).to_return(
      File.new('spec/lib/crawlers/thz/fixtures/thread-1922004-1-1.html'),
    )
    stub_request(:get, %r{/imc_attachad-ad.html}).to_return(
      File.new('spec/lib/crawlers/thz/fixtures/imc_attachad-ad.html'),
    )
  end

  describe '.crawl_censored' do
    it 'crawls forum' do
      expect(crawler).to receive(:crawl_forum).twice.with(
        anything, tag: '桃花族', backfill: false
      ).and_call_original
      crawler.crawl_censored page: 1, backfill: false
    end

    it 'creates resources' do
      crawler.crawl_censored page: 1, backfill: false
      expect(Resource.first).to have_attributes(
        source_uri: 'http://thz5.cc/thread-213795-1-1.html',
        download_uri: end_with(
          "#{CGI.escape('桃花族')}/#{CGI.escape('[ThZu.Cc]ofje-178.torrent')}",
        ),
        tags: ['桃花族'],
      )
    end
  end
end
