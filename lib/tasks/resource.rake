require 'open-uri'

namespace :load do
  desc 'load resources'
  task :resources, %i[uri note] => :environment do |_, args|
    unrecognized = []
    open(args[:uri]).each do |line|
      tokens = line.strip.split
      uri = tokens[1]
      next if Resource.exists?(download_uri: uri)
      code = File.basename(tokens[0], '.*').upcase
      if code =~ /\d*([[:alnum:]]+?)0*(\d+)/
        code = "#{$1}-#{$2}"
      end
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
