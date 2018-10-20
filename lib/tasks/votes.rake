require 'open-uri'

namespace :votes do
  desc 'load votes'
  task :load, %i[email vote uri force] => :environment do |_, args|
    user = User.find_by_email!(args[:email])
    voted = []
    duplicate = []
    failed = []
    open(args[:uri]).each do |code|
      begin
        code.strip!
        movie = Movie.search!(code)
        movie.votes.where(user: user).destroy_all if args[:force]
        movie.votes.create!(user: user, status: args[:vote])
        voted << movie.code
      rescue ActiveRecord::RecordInvalid
        duplicate << code
      rescue ActiveRecord::RecordNotFound
        failed << code
      end
    end
    puts "#{duplicate.size} duplicate: #{duplicate}"
    puts "#{voted.size} voted: #{voted}"
    puts "#{failed.size} failed: #{failed}"
  end
end
