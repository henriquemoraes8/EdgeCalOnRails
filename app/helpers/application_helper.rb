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

  def times_overlap(start_1, end_1, start_2, end_2)
    (start_1-end_2)*(start_2-end_1) > 0
  end

  def events_overlap(event_1, event_2)
    times_overlap(event_1.start_time, event_1.end_time, event_2.start_time, event_2.end_time)
  end

  def slots_overlap(slot_1, slot_2)
    times_overlap(slot_1.start_time, slot_1.end_time, slot_2.start_time, slot_2.end_time)
  end

  def time_in_seconds(time)
    time.hour*3600 + time.min*60
  end

end
