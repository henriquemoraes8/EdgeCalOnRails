class TimeSlotController < ApplicationController

  def index
    @events = current_user.get_time_slot_created_events
    @assigned_time_slots = current_user.time_slots

  end

  def new
    @event = Event.new(:event_type => Event.event_types[:time_slot])
  end

  def destroy
    event = Event.find_by_id(params[:id])
    event.destroy
    flash[:notice] = "Slot Block #{event.title} deleted successfully"
    redirect_to(time_slot_index_path)
  end

end
