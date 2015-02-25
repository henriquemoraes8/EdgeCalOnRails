class EventsController < ApplicationController
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
    @event = Event.new(event_params)

    ##### fails
    @event.creator_id = current_user.id   
    ### @brianbolze -- throws error in test 
    ### NoMethodError: undefined method `id' for nil:NilClass

    puts "MASS ASSIGNED EVENT IS #{@event}"

    respond_to do |format|
      if @event.save
        puts "SUCCESSFUL SAVE"
        @subscription = Subscription.new(subscribed_event_id: @event.id,subscriber_id: current_user.id)
        @subscription.visibility = params[:subscription_visibility].to_i
        @subscription.save

        if !params[:event][:reminder][:next_reminder_time].blank?
          puts "WILL CREATE EVENT REMINDER"
          puts "WHAT AM I DOING HERE EXACTLY?"
          if !@subscription.set_reminder(params[:event][:reminder])
            puts "WHAT AM I DOING HERE EXACTLY?"
            render('new')
            return
          end
        end

        format.html { redirect_to events_path, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        puts "DID NOT SAVE"
        puts @event.errors.full_messages
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    puts "MASS ASSIGNED EVENT FROM UPDATE IS #{@event}"
    respond_to do |format|
      if @event.update(event_params)
        require "events_controller"

        if !params[:event][:visibility][:status].blank?
          @event.set_visibility(params[:event][:visibility])
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
  
  # GET /busy_events.json
  def busy_events
    # render json: current_user.get_busy_events
    @events = current_user.get_busy_events
    render 'busy.json.jbuilder'
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
