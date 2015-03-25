module ApplicationHelper
  
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def cp(path)
    "active" if current_page?(path)
  end

  def title(page_title)
    content_for :title, page_title.to_s
  end

  def error_messages_for(object)
    render(:partial => 'application/error_messages', :locals => {:object => object})
  end

  def to_eastern_time(time)
    time.in_time_zone('Eastern Time (US & Canada)')
  end

  def correct_time_from_datepicker(time)
    time = to_eastern_time(DateTime.parse(time))
    time -= time.utc_offset.seconds
    time
  end

  def to_second(time)
    time.hour*3600 + time.min*60
  end

  def round_second(time)
    time.change(:sec => 0)
  end


end
