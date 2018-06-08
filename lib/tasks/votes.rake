require 'open-uri'

namespace :votes do
  desc 'load votes'
  task :load, %i[email vote uri] => :environment do |_, args|
    user = User.find_by_email!(args[:email])
    unrecognized = []
    open(args[:uri]).each do |code|
      begin
        code.strip!
        movie = Movie.search!(code)
        vote = movie.votes.create(user: user, status: args[:vote])
      rescue ActiveRecord::RecordNotFound
        unrecognized << code
      end
    end
    puts "#{unrecognized.size} unrecognized:"
    puts unrecognized
  end
end
