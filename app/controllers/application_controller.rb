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
  
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def to_eastern_time(time)
    time.in_time_zone('Eastern Time (US & Canada)')
  end

  def correct_time_from_datepicker(time)
    if time.blank?
      return nil
    end
    adjust_time_zone_offset(DateTime.parse(time))
  end

  def adjust_time_zone_offset(time)
    time = to_eastern_time(time)
    time -= time.utc_offset.seconds
    time
  end

  def to_second(time)
    time.hour*3600 + time.min*60
  end

  def round_second(time)
    time.change(:sec => 0)
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end
  
  helper :all

end
