################################################################
# The TimeSlot controller is used to manage everything involved
# with signing up for slots/appointments. 
################################################################


class TimeSlotController < ApplicationController
  
  helper_method :preference_based
  
  def index
    @events = current_user.get_time_slot_created_events
    @assigned_time_slots = current_user.time_slots
    @users = User.all.where.not(:id => current_user.id)
  end

  def new
    @events = []
    @events << Event.new(:event_type => Event.event_types[:time_slot_block])
    @users = User.all.where.not(:id => current_user.id)
    @groups = current_user.groups
  end

  def create
    rep_params = params[:event_blocks][:repetition_scheme]
    min_duration = rep_params['min_duration(4i)'].to_i*3600 + rep_params['min_duration(5i)'].to_i*60
    max_duration = rep_params['max_duration(4i)'].to_i*3600 + rep_params['max_duration(5i)'].to_i*60
    puts "*** CREATE ***"
    puts "min #{min_duration} max #{max_duration}"

    if min_duration == 0 || max_duration == 0
      flash[:error] = "you must set minimum and maximum durations"
      redirect_to time_slot_new_path
      return
    end

    if min_duration > max_duration
      flash[:error] = "your minimum duration must be less than or equal to your maximum duration"
      redirect_to time_slot_new_path
      return
    end

    if params[:event_blocks][:preference] == '1'
      status = RepetitionScheme.statuses[:preference_based]
    else
      status = RepetitionScheme.statuses[:regular]
    end

    repetition = RepetitionScheme.create(:min_time_slot_duration => min_duration, :max_time_slot_duration => max_duration,
                      status: status, creator_id: current_user.id)
    puts "REP SCHEME #{repetition}"

    title = params[:event_blocks][:title]
    description = params[:event_blocks][:description]

    all_users = []
    params[:user_participant].keys.each do |u|
      if params[:user_participant][u] == '1'
        all_users << u.to_i
        # puts User.where(id: u).name
      end
    end
    unless params[:group_participant].blank?
      params[:group_participant].keys.each do |g|
        if params[:group_participant][g] == '1'
          all_users << g.all_user_ids
        end
      end
    end
    puts "ALL_USERS RESULT #{all_users}"
    all_users = all_users.flatten.uniq
    if all_users.empty?
      flash[:error] = "you must select participants or groups for your slot event"
      repetition.destroy
      redirect_to time_slot_new_path
      return
    end
    all_users.map {|u| repetition.allowed_users << User.find(u)}
    
    params[:event_blocks][:events].each do |e_param|
      e_param[:title] = title
      e_param[:description] = description
      e_param[:start_time] = correct_time_from_datepicker(e_param[:start_time])
      e_param[:end_time] = correct_time_from_datepicker(e_param[:end_time])
      e_param[:event_type] = Event.event_types[:time_slot_block]
      event = Event.new(event_params(e_param))
      puts "WILL CREATE EVENT PREFERENCE BASED #{event}"
      
      event.creator_id = current_user.id
      if event.save
        repetition.events << event
      else
        flash[:error] = "Error in submission, try again: #{event.errors.full_messages}"
        repetition.destroy
        redirect_to time_slot_new_path
        return
      end
    end

    puts "WILL CHECK CREATE_TO_DO PARAMS #{params[:create_to_do]}"
    if params[:event_blocks][:create_to_do] == '1'
      position = params[:event_blocks][:to_do_priority].to_i
      repetition.generate_to_dos_with_position(position == 0 ? 1 : position)
    end

    flash[:notice] = "slot assignment created successfully"
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
  
  def show_invitees
    event = Event.find_by_id(params[:id])
    @invitees = event.repetition_scheme.allowed_users
    render '_invitees', layout: false
    return
  end
  
  def scheduler
    @event = Event.find_by_id(params[:id])
    $slots = Hash.new
    @allowed_users = @event.repetition_scheme.allowed_users
  end
  
  def assign_user_to_slot
    user = params[:user]
    slot = params[:slot]
    $slots[user] = slot
    render 'scheduler'
    return
  end
  
  def choose_slot_preferences
    params[:preference_signup].each do |e_id, e_hash|
      event = Event.find(e_id.to_i)
      duration = event.repetition_scheme.min_time_slot_duration
      start_time = e_hash['slot_time']
      puts "START #{start_time} DURATION #{duration}"
      slot = TimeSlot.new(:start_time => start_time, :duration => duration,
                          :event_id => event.id, :user_id => current_user.id, :preference => e_hash['preference'])
      
      if slot.save
        flash[:notice] = "Preference successfully saved!"
        event.time_slots << slot
      else
        flash[:error] = "Error submitting slot preference!"
        redirect_to time_slot_index_path
        return
      end

    end
    redirect_to time_slot_index_path
  
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
        flash[:notice] = "Successfully Signed Up!"
        event.time_slots << slot
      else
        flash[:error] = slot.errors[:base]
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

  def add_event_block
    respond_to do |format|               
      format.js
    end
  end
  
  def get_allowed_users
    event = params[:id]
    repetition = event.repetition_scheme
    @allowed_users = repetition.allowed_users
  end
  
  def preference_based(event)
    return RepetitionScheme.statuses[event.repetition_scheme.status] == RepetitionScheme.statuses[:preference_based]
  end

  private

  def event_params(e_param)
    e_param.permit(:title, :description, :start_time, :end_time, :event_type)
  end

end
