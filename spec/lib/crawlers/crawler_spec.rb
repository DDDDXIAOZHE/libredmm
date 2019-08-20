# frozen_string_literal: true

require "rails_helper"
require "crawlers/crawler"

RSpec.describe Crawler do
  let(:crawler) { Crawler.new }
  let(:tag) { "TAG" }

  before(:each) do
    allow(crawler).to receive(:extract_thread_links_from_forum).and_return(
      [spy("thread_link")],
    )
    allow(crawler).to receive(:extract_next_page_link_from_forum).and_return(
      spy("next_page_link"),
    )
    allow(crawler).to receive(:extract_title_from_thread).and_return(
      "CODE-123",
    )
    allow(crawler).to receive(:extract_dl_link_from_thread).and_return(
      spy("dl_link"),
    )
  end

  describe ".crawl_forum" do
    it "parses threads" do
      expect(crawler).to receive(:parse_thread).at_least(:once).and_call_original
      allow(crawler).to receive(:extract_next_page_link_from_forum).and_return(nil)
      crawler.crawl_forum spy("forum_page"), tag: tag, backfill: false
    end

    it "uploads to s3" do
      expect(crawler).to receive(:upload_torrent).at_least(:once).and_call_original
      allow(crawler).to receive(:extract_next_page_link_from_forum).and_return(nil)
      crawler.crawl_forum spy("forum_page"), tag: tag, backfill: false
    end

    it "creates resources with correct tag" do
      expect {
        crawler.crawl_forum spy("forum_page"), tag: tag, backfill: false
      }.to change {
        Resource.where(tags: [tag]).count
      }
    end

    context "when not backfilling" do
      it "stops at current page if no new resource" do
        expect(crawler).to receive(:crawl_forum).once.and_call_original
        allow(crawler).to receive(:extract_thread_links_from_forum).and_return([])
        crawler.crawl_forum spy("forum_page"), tag: tag, backfill: false
      end

      it "continues to next page if new resource found" do
        expect(crawler).to receive(:crawl_forum).twice.and_call_original
        allow(crawler).to receive(:extract_thread_links_from_forum).and_return(
          [spy("thread_link")], []
        )
        crawler.crawl_forum spy("forum_page"), tag: tag, backfill: false
      end

      context "on repeatedly crawling" do
        before(:each) do
          allow(crawler).to receive(:extract_thread_links_from_forum).and_return(
            [spy("thread_link")], []
          )
          crawler.crawl_forum spy("forum_page"), tag: tag, backfill: false
        end

        it "stops at current page when repeatedly crawling" do
          expect(crawler).to receive(:crawl_forum).once.and_call_original
          allow(crawler).to receive(:extract_thread_links_from_forum).and_return(
            [spy("thread_link")], []
          )
          crawler.crawl_forum spy("forum_page"), tag: tag, backfill: false
        end

        it "does not parse thread pages" do
          allow(crawler).to receive(:extract_thread_links_from_forum).and_return(
            [spy("thread_link")], []
          )
          expect(crawler).not_to receive(:extract_title_from_thread)
          crawler.crawl_forum spy("forum_page"), tag: tag, backfill: false
        end
      end
    end

    context "when backfilling" do
      it "continues to next page even if no new resource found" do
        expect(crawler).to receive(:crawl_forum).twice.and_call_original
        allow(crawler).to receive(:extract_thread_links_from_forum).and_return([])
        allow(crawler).to receive(:extract_next_page_link_from_forum).and_return(
          spy("next_page_link"), nil
        )
        crawler.crawl_forum spy("forum_page"), tag: tag, backfill: true
      end
    end
  end
end
