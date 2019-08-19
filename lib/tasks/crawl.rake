# frozen_string_literal: true

require 'open-uri'
require 'crawlers/sht'
require 'crawlers/thz'

namespace :crawl do
  namespace :thz do
    desc 'Crawl 桃花族 亚洲有码原创'
    task :censored, %i[start_index backfill] => :environment do |_, args|
      ThzCrawler.new.crawl_censored(
        page: args.fetch(:page, 1),
        backfill: args.fetch(:backfill, false),
      )
    end
  end

  namespace :sht do
    desc 'Crawl 色花堂 高清中文字幕'
    task :subtitled, %i[start_index backfill] => :environment do |_, args|
      ShtCrawler.new.crawl_subtitled(
        page: args.fetch(:page, 1),
        backfill: args.fetch(:backfill, false),
      )
    end

    desc 'Crawl 色花堂 亚洲有码原创'
    task :censored, %i[start_index backfill] => :environment do |_, args|
      ShtCrawler.new.crawl_censored(
        page: args.fetch(:page, 1),
        backfill: args.fetch(:backfill, false),
      )
    end
  end
end
