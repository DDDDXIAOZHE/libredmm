require 'open-uri'

namespace :load do
  desc 'load votes'
  task :votes, %i[email vote uri] => :environment do |_, args|
    user = User.find_by_email!(args[:email])
    unrecognized = []
    open(args[:uri]).each do |code|
      begin
        code.strip!
        movie = Movie.search!(code)
        puts movie.inspect
        vote = movie.votes.create(user: user, status: args[:vote])
        puts vote.inspect
      rescue ActiveRecord::RecordNotFound
        unrecognized << code
      end
    end
    puts "#{unrecognized.size} unrecognized:"
    puts unrecognized
  end
end
