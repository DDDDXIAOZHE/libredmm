class PagesController < ApplicationController
  def search
    redirect_to Movie.search!(params[:q])
  rescue ActiveRecord::RecordNotFound
    redirect_to movies_url(fuzzy: params[:q])
  end
end
