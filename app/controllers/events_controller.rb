class EventsController < ApplicationController

  ################################################################
  # The events controller is also the home page of our webpage,
  # and contains the calendar in its view, with all visible events
  # displayed.  It also contains the calls that determine what
  # events look like in the calendar view, and has a form that
  # allows the user to create a new event.
  ################################################################

  require 'mailgun'

  before_action :set_event, only: [:show, :edit, :update, :delete]
    
  # GET /events
  # GET /events.json
  def index
    # @events = Event.between(params['start'], params['end']) if (params['start'] && params['end']) 
    @events = current_user.get_visible_events
    
    @own_events = current_user.created_events
    @visible_events = current_user.get_visible_events
    @modifiable_events = current_user.get_modifiable_events
    @busy_events = current_user.get_busy_events
    @date = params[:month] ? Date.parse(params[:month]) : Date.today

    @friends = User.all


  end

  # GET /events/new
  def new
    @event = Event.new
    return @event
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @subscription = Subscription.where(subscribed_event_id: params[:id]).where(subscriber_id: current_user.id).first
    @groups = current_user.groups
    @visibility_count = @event.visibilities.count
  end

  # POST /events
  # POST /events.json
  def create
    if params[:event][:repetition][:recurrence] != 'no_recurrence'
      params[:event][:event_type] = Event.event_types[:recurrent]
    end

    params[:event][:start_time] = correct_time_from_datepicker(params[:event][:start_time])
    params[:event][:end_time] = correct_time_from_datepicker(params[:event][:end_time])
    @event = Event.new(event_params)

    @event.creator_id = current_user.id   
    ### NoMethodError: undefined method `id' for nil:NilClass

    puts "MASS ASSIGNED EVENT IS #{@event}"

    respond_to do |format|
      if @event.save
        # Save was successful
        puts "SUCCESSFUL SAVE"
        puts "event_id #{@event.id} USER ID #{current_user.id}"
        @subscription = current_user.subscribe_to_event(@event)

        # Reminder creation logic here.  If the form at the bottom of the page
        # is not empty, the reminder will be set, and emails will be sent to
        # the user based on the times set.
        if !params[:event][:reminder][:next_reminder_time].blank?
          puts "WILL CREATE EVENT REMINDER"
          if !@subscription.set_reminder(params[:event][:reminder])
            render('new')
            return
          end
        end

        puts "EVENT TYPE #{@event.event_type} REPRESENTATION: #{Event.event_types[:recurrent]}"
        if @event.event_type == 'recurrent' && !params[:event][:repetition][:until].blank?
          repetition = RepetitionScheme.new
          date = Time.parse("#{params[:event][:repetition][:until]} Eastern Time (US & Canada)")
          #TODO: throw error otherwise
          puts "RECURRENT EVENT WILL TRY TO CREATE REPETITION UNTIL #{date}, EVENT END #{@event.end_time} RESULT #{date > @event.end_time}"
          if date > @event.end_time
            repetition = RepetitionScheme.create
            repetition.create_events_with_recurrence(@event, date, params[:event][:repetition][:recurrence])
          end
        end

        # For JavaScript, JQuery, etc
        format.html { redirect_to events_path, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        # Save was not successful, send erros
        puts "DID NOT SAVE"
        puts @event.errors.full_messages
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    puts "MASS ASSIGNED EVENT FROM UPDATE IS #{@event}"

    respond_to do |format|
      if @event.update(event_params)
        require "events_controller"

        if !params[:event][:visibility][:status].blank?
          # If visibility is something other than the default value,
          # set it to the new type of visibility.
          @event.set_visibility(params[:event][:visibility])
        end

        puts "CHECK IF RECURRENT #{@event.event_type} AND EQUALITY #{@event.event_type == 'recurrent'}"
        if @event.event_type == 'recurrent'
          @event.repetition_scheme.update_events_based_on_event(@event)
        end

        format.html { redirect_to events_path, notice: 'Event was successfully updated.' }
        format.json { render :index, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def delete
    puts "WILL DESTROY, EVENT PARAMS: #{params}"
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event #{@event.title} was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  # GET /events/busy_events.json
  def busy_events
    # render json: current_user.get_busy_events
    @events = current_user.get_busy_events
    render 'busy.json.jbuilder'
  end
  
  # GET /events/invited_events.json
  def invited_events
    # render json: current_user.get_busy_events
    @events = current_user.requests
    render 'invited_events.json.jbuilder'
  end
  
  # GET /events/PUD_events.json
  def PUD_events
    @events = Event.where(creator: current_user, event_type: Event.event_types[:to_do])
    render 'index.json.jbuilder'
  end
  
  # GET /events/created_events.json
  def created_events
    @events = Event.where(creator: current_user, event_type: [Event.event_types[:recurrent], Event.event_types[:regular]])
    render 'index.json.jbuilder'
  end
  
  # GET /events/visible_events.json
  def visible_events
    @events = current_user.get_visible_events - Event.where(creator: current_user)
    render 'show.json.jbuilder'
  end
  
  # GET /events/1/get_subscribers
  def get_subscribers
    @event = Event.find(params[:id])
    @subscribers = 'Brian'
    respond_to do |format|
      format.js { render json: @event}
    end
  end

  def create_html_email
    @own_events = current_user.created_events
    @visible_events = current_user.get_visible_events
    @modifiable_events = current_user.get_modifiable_events
    @busy_events = current_user.get_busy_events
    @date = params[:month] ? Date.parse(params[:month]) : Date.today

    start_date = correct_time_from_datepicker(params[:events_email][:start_date])
    end_date = correct_time_from_datepicker(params[:events_email][:end_date])
    
    @events = current_user.get_visible_events
    @in_range_events = []
    puts "START DATE IS HERE"
    puts start_date
    puts "NOW"
    @events.each do |e|
      puts "New Event"
      puts e.start_time

      if e.start_time>=start_date && e.end_time<=end_date
        puts "CORRECT"
        @in_range_events << e
      end
    end

    html = render_to_string(:template => "events/_list_index", :layout => false)

    puts "USER EMAIL IS: " + current_user.email

    #mg_client = Mailgun::Client.new "key-345efdd486ec59509f9161b99b78d333"

    # Define your message parameters
    puts "SENDING EMAIL HERE"

    RestClient.post "https://api:key-345efdd486ec59509f9161b99b78d333"\
    "@api.mailgun.net/v3/sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org/messages",
      :from => "EdgeCal Team <mailgun@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org>",
      :to => current_user.email,
      :subject => "Here's your schedule!",
      :html => html.to_str

    puts "EMAIL OFFICIALLY SENT"

    # A strange bug is happening, so I'm putting this here for now because
    # it kinda fixes it.  Need to figure out what's happening
    render 'index.html'
  end
  
  
  ######################
  ### MODALS ##########
  ######################
  
  def requests_modal
    @request_maps = []
    current_user.get_requested_events.map {|e| @request_maps << e.request_map}
    render '_request_list', layout: 'modal'
    return
  end
  
  def new_event_modal
    @event = Event.new
    render 'new', layout: 'modal'
    return
  end
  
  def to_do_list_modal
    @todos = ToDo.where(creator_id: current_user.id)
    render '_to_do_list', layout: 'modal'
    return
  end
  
  def event_list_reveal_modal
    event = Event.find_by_id(params[:id])
    @invitees = event.repetition_scheme.allowed_users
    render '_invitees', layout: 'modal'
    return
  end

  def show_graphic_cal
    start_date=correct_time_from_datepicker(params[:graphic_calendar][:start_date])
    end_date=correct_time_from_datepicker(params[:graphic_calendar][:end_date])
    @events = current_user.get_visible_events
    @in_range_events = []
    puts "START DATE IS HERE"
    puts start_date
    puts "NOW"
    @events.each do |e|
      puts "New Event"
      puts e.start_time

      if e.start_time>=start_date && e.end_time<=end_date
        puts "CORRECT"
        @in_range_events << e
      end
    end

    pdf = render_to_string pdf: "test_file", template: "events/show_graphic_cal.html.erb"
    save_path = Rails.root.join('Documentation','filename.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
    #render 'show_graphic_cal.json.jbuilder'
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:title, :description, :start_time, :end_time, :event_type)
    end
end
