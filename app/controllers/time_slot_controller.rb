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
    @events = []
    if !params[:e_id].blank?
      event = Event.find(params[:e_id])
      event.repetition_scheme.events.map {|e| @events << e}
    else
      @events = @user.get_time_slot_created_events
    end
  end

  def assign_time_slots
    params[:event_signup].each do |e_id, e_hash|
      event = Event.find(e_id.to_i)
      slot = TimeSlot.new(:start_time => e_hash['slot_time'], :duration => e_hash['slot_duration'].to_i*60,
                          :event_id => event.id, :user_id => current_user.id)
      puts "START #{slot.start_time} DURATION #{slot.duration} E_ID #{slot.event_id}"

      # if user already has a slot in this event remove it
      if !event.time_slots.where(:user_id => current_user.id).empty?
        event.time_slots.where(:user_id => current_user.id).first.destroy
      end

      if slot.save
        event.time_slots << slot
      else
        flash[:notice] = slot.errors[:base]
        redirect_to signup, :id => event.creator_id
        return
      end

    end
    redirect_to time_slot_index_path
  end

  def destroy
    event = Event.find_by_id(params[:id])
    event.destroy
    flash[:notice] = "Slot Block #{event.title} deleted successfully"
    redirect_to(time_slot_index_path)
  end

  def destroy_slot
    slot = TimeSlot.find(params[:id])
    flash[:notice] = "slot for event #{slot.event.title} at #{slot.start_time.strftime("%-d %b - %H:%M")} cancelled successfully"
    slot.destroy
    redirect_to time_slot_index_path
  end

  private

  def event_params(e_param)
    e_param.permit(:title, :description, :start_time, :end_time)
  end

end
