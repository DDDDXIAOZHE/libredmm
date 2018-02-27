require 'open-uri'
require 'crawler/thz'

namespace :crawl do
  desc 'crawl thzvvv.com'
  task :thz => :environment do
    ThzCrawler.new.crawl
  end

  namespace :thz do
    desc 'backfill thzvvv.com'
    task :backfill => :environment do
      ThzCrawler.new.backfill
    end
  end
end
