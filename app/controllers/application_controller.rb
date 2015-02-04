class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  if Rails.env.production?
    before_action :authenticate_user!
  end


  #After sign in, go to events page
  def after_sign_in_path_for(resource)
  	events_path
  end

end
