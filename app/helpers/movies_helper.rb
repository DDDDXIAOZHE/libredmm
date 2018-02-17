module MoviesHelper
  def upvote_link(movie, height: 32)
    vote_link(movie, 'up', 'thumbsup', height: height)
  end

  def downvote_link(movie, height: 32)
    vote_link(movie, 'down', 'thumbsdown', height: height)
  end

  def vote_link(movie, status, icon, height: 32)
    if movie.votes.find_by(user: current_user).try(:status) == status
      link_to movie_vote_url(movie), method: :delete, class: 'text-primary align-bottom' do
        octicon icon, height: height
      end
    else
      link_to movie_vote_url(movie, vote: { status: status }), method: :put, class: 'text-secondary' do
        octicon icon, height: height
      end
    end
  end
end
