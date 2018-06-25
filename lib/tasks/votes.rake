require 'open-uri'

namespace :votes do
  desc 'load votes'
  task :load, %i[email vote uri] => :environment do |_, args|
    user = User.find_by_email!(args[:email])
    voted = []
    failed = []
    open(args[:uri]).each do |code|
      begin
        code.strip!
        movie = Movie.search!(code)
        movie.votes.create(user: user, status: args[:vote])
        voted << movie.code
      rescue ActiveRecord::RecordNotFound
        failed << code
      end
    end
    puts "#{voted.size} voted: #{voted}"
    puts "#{failed.size} failed: #{failed}"
  end
end
