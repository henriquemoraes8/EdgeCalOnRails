class SubscriptionController < ApplicationController


  def index
    @users = User.where.not(id: current_user.id)
    puts "**** PARAMS: #{params}"
    @selected_user = params[:id].blank? ? @users.first : User.find(params[:id])
    puts "***** SELECTED USER: #{@selected_user}"
    @events = @selected_user.created_events
    puts "**** EVENT SIZE: #{@events.count}"
    @events.each do |e|
      puts e.title
      puts e.description
    end
  end

  def manage
    puts "*** GOT TO MANAGE ****"
    puts "PARAMS IS: #{params}"
    params[:events].keys.each do |event_id|
      event = Event.find(event_id)
      if params[:events][event_id] == "1"
        puts "ADD SUBS TO EVENT #{event.id}"
        current_user.subscribe_to_event(event)
      elsif params[:events][event_id] == "0"
        puts "REMOVE SUBS TO EVENT #{event.id}"
        current_user.unsubscribe_to_event(event)
      end

    end
    redirect_to(subscription_index_path(params[:id]))
  end
end
