module MoviesHelper
  def upvote_link(movie)
    vote_link(movie, 'up', 'thumbsup')
  end

  def downvote_link(movie)
    vote_link(movie, 'down', 'thumbsdown')
  end

  def vote_link(movie, status, icon)
    if movie.votes.find_by(user: current_user).try(:status) == status
      link_to movie_vote_url(movie), method: :delete, class: 'text-primary align-bottom' do
        octicon icon, height: 32
      end
    else
      link_to movie_vote_url(movie, vote: { status: status }), method: :put, class: 'text-secondary' do
        octicon icon, height: 32
      end
    end
  end
end
