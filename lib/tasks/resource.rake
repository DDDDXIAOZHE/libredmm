require 'open-uri'

namespace :load do
  desc 'load resources'
  task :resources, %i[uri note] => :environment do |_, args|
    unrecognized = []
    open(args[:uri]).each do |line|
      next unless line.strip =~ /(.+)\s+(http.+)/
      path = $1
      uri = $2
      next if Resource.exists?(download_uri: uri)
      code = File.basename(path, '.*').upcase.gsub(/^\d*/, '')
      begin
        Movie.search!(code).resources.create!(download_uri: uri, note: args[:note])
      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
        unrecognized << code
      end
    end
    puts "#{unrecognized.size} unrecognized:"
    puts unrecognized
  end
end
