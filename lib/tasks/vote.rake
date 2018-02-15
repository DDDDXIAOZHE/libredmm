require 'open-uri'

namespace :movie do
  desc 'vote movies'
  task :vote, [:email, :vote, :url] => :environment do |t, args|
    user = User.find_by_email!(args[:email])
    unrecognized = []
    open(args[:url]).each do |code|
      begin
        code.strip!
        movie = Movie.search!(code)
        vote = Vote.find_or_initialize_by(user: user, movie: movie)
        vote.status = args[:vote]
        vote.save!
      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
        unrecognized << code
      end
    end
    puts "#{unrecognized.size} unrecognized:"
    puts unrecognized
  end
end