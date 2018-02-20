module MoviesHelper
  def vote_link(movie, status, icon, height)
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
