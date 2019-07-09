# frozen_string_literal: true

require 'open-uri'
require 'crawlers/thz'

namespace :crawl do
  desc 'crawl thzvvv.com'
  task :thz => :environment do
    ThzCrawler.new.crawl
  end

  namespace :thz do
    desc 'backfill thzvvv.com'
    task :backfill, %i[start_index] => :environment do |_, args|
      ThzCrawler.new.backfill args.fetch(:start_index, 1)
    end
  end
end
