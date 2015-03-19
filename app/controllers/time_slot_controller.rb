class TimeSlotController < ApplicationController

  def index
    @events = current_user.get_time_slot_created_events
    @assigned_time_slots = current_user.time_slots
    @users = User.all.where.not(:id => current_user.id)
  end

  def new
    @events = []
    @events << Event.new(:event_type => Event.event_types[:time_slot])
  end

  def create
    rep_params = params[:event_blocks][:repetition_scheme]
    min_duration = rep_params['min_duration(4i)'].to_i*3600 + rep_params['min_duration(5i)'].to_i*60
    max_duration = rep_params['max_duration(4i)'].to_i*3600 + rep_params['max_duration(5i)'].to_i*60
    puts "*** CREATE ***"
    puts "min #{min_duration} max #{max_duration}"

    if min_duration == 0 || max_duration == 0
      flash[:notice] = "you must set minimum and maximum durations"
      redirect_to time_slot_new_path
      return
    end

    repetition = RepetitionScheme.create(:min_time_slot_duration => min_duration, :max_time_slot_duration => max_duration)

    params[:event_blocks][:events].each do |e_param|
      event = Event.new(event_params(e_param))
      event.event_type = Event.event_types[:time_slot]
      event.creator_id = current_user.id
      if event.save
        repetition.events << event
      else
        @event = event
        redirect_to time_slot_new_path
      end
    end

    redirect_to(time_slot_index_path)
  end

  def signup
    @user = User.find(params[:id])
    @events = @user.get_time_slot_created_events
  end

  def assign_time_slots
    
    redirect_to time_slot_index_path
  end

  def destroy
    event = Event.find_by_id(params[:id])
    event.destroy
    flash[:notice] = "Slot Block #{event.title} deleted successfully"
    redirect_to(time_slot_index_path)
  end

  private

  def event_params(e_param)
    e_param.permit(:title, :description, :start_time, :end_time)
  end

end
