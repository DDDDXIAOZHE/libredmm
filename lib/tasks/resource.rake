require 'open-uri'

namespace :load do
  desc 'load resources'
  task :resources, %i[uri note] => :environment do |_, args|
    dict = Marshal.load(open(args[:uri]))
    unrecognized = []
    dict.each do |code, uri|
      next if Resource.exists?(download_uri: uri)
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
