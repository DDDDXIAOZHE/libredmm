module MoviesHelper
  def link_to_open_all(movies)
    link_to(
      'Open all in new tabs',
      '#',
      data: {
        urls: movies.map(url_for).join(','),
      },
      class: 'open-all',
    )
  end

  def link_to_vote(movie, status, icon, height)
    return nil unless signed_in?

    vote = movie.votes.find do |v|
      v.user_id == current_user.id
    end
    if vote && vote.status == status
      link_to(
        movie_vote_url(movie),
        method: :delete,
        class: 'text-primary align-bottom',
      ) do
        octicon icon, height: height
      end
    else
      link_to(
        movie_vote_url(movie, vote: { status: status }),
        method: :put,
        class: 'text-secondary',
      ) do
        octicon icon, height: height
      end
    end
  end
end
