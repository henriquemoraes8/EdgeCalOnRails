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


end
