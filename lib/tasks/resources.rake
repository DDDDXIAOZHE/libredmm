require 'open-uri'

namespace :resources do
  namespace :load do
    desc 'load hd1080.org resources'
    task :hd1080, %i[dump_uri] => :environment do |_, args|
      unrecognized = []
      open(args[:dump_uri]).each do |line|
        next unless line.strip =~ /(.+)\s+(http.+)/
        path = Regexp.last_match(1)
        uri = Regexp.last_match(2)
        next if Resource.exists?(download_uri: uri)
        code = File.basename(path, '.*').upcase.gsub(/^\d*/, '')
        begin
          Movie.search!(code).resources.create!(download_uri: uri, note: 'Password: https://www.myhd1080.tv')
        rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
          unrecognized << code
        end
      end
      puts "#{unrecognized.size} unrecognized:"
      puts unrecognized
    end
  end

  namespace :obsolete do
    desc 'obsolete bt resources'
    task :bt, %i[email dump_uri] => :environment do |_, args|
      user = User.find_by_email!(args[:email])
      failed = []
      open(args[:dump_uri]).each do |code|
        begin
          code.strip!
          movie = Movie.search!(code)
          movie.resources.in_bt.update_all(is_obsolete: true)
          Vote.where(user: user, movie: movie, status: :bookmark).destroy_all
        rescue ActiveRecord::RecordNotFound
          failed << code
        end
      end
      puts "#{failed.size} failed:"
      puts failed
    end
  end
end
