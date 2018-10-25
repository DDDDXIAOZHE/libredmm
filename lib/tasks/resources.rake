require 'open-uri'

namespace :resources do
  namespace :load do
    desc 'load hd1080.org resources'
    task :hd1080, %i[dump_uri] => :environment do |_, args|
      duplicate = []
      failed = []
      loaded = []
      URI.parse(args[:dump_uri]).open.each do |line|
        next unless line.strip =~ /(.+)\s+(http.+)/

        path = Regexp.last_match(1)
        uri = Regexp.last_match(2)
        code = File.basename(path, '.*').upcase.gsub(/^\d*/, '')
        if Resource.exists?(download_uri: uri)
          duplicate << code
          next
        end
        begin
          tries ||= 5
          movie = Movie.search!(code)
          movie.resources.create!(
            download_uri: uri,
            note: 'Password: https://www.myhd1080.tv',
          )
        rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
          retry if (tries -= 1) > 0
          failed << code
        else
          loaded << movie.code
        end
      end
      puts "#{duplicate.size} duplicate: #{duplicate}"
      puts "#{loaded.size} loaded: #{loaded}"
      puts "#{failed.size} failed: #{failed}"
    end
  end

  namespace :obsolete do
    desc 'obsolete bt resources'
    task :bt, %i[email dump_uri] => :environment do |_, args|
      user = User.find_by_email!(args[:email])
      obsoleted = []
      failed = []
      URI.parse(args[:dump_uri]).open.each do |code|
        begin
          code.strip!
          movie = Movie.search!(code)
          movie.resources.in_bt.update_all(is_obsolete: true)
          Vote.where(user: user, movie: movie, status: :bookmark).destroy_all
          obsoleted << movie.code
        rescue ActiveRecord::RecordNotFound
          failed << code
        end
      end
      puts "#{obsoleted.size} obsoleted: #{obsoleted}"
      puts "#{failed.size} failed: #{failed}"
    end
  end
end
