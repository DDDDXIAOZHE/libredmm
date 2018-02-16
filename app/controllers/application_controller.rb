class ApplicationController < ActionController::Base
  include Clearance::Controller
  protect_from_forgery with: :exception

  helper_method :signed_in_as_admin?
  def signed_in_as_admin?
    signed_in? && current_user.is_admin?
  end
end
