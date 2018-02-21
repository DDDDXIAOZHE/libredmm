class ResourcesController < ApplicationController
  before_action :require_login

  def show
    @resource = Resource.find(params[:id])
    @resource.movie.votes.create(user: current_user, status: :bookmark)
    redirect_to @resource.download_uri
  end
end
