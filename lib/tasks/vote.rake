require 'open-uri'

namespace :movie do
  desc 'vote movies'
  task :vote, [:email, :vote, :url] => :environment do |t, args|
    user = User.find_by_email!(args[:email])
    puts user.inspect
    open(args[:url]).each do |code|
      begin
        puts code
        code = code.strip
        movie = Movie.find_or_create_by!(code: code)
        vote = Vote.find_or_initialize_by(user: user, movie: movie)
        vote.status = args[:vote]
        vote.save!
        puts vote.inspect
      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
      end
    end
  end
end