class ResourcesController < ApplicationController
  before_action :require_login

  def show
    @resource = Resource.find(params[:id])
    @resource.movie.votes.create(user: current_user, status: :bookmark)
    redirect_to @resource.download_uri
  end

  def destroy
    @resource = Resource.find(params[:id])
    @resource.update(is_obsolete: true)
    @resource.movie.votes.where(user: current_user, status: :bookmark).destroy_all
    redirect_to @resource.movie
  end
end
