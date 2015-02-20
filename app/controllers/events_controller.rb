class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @subscription = Subscription.where('subscriber_id = ?',current_user.id)

    #Subscription.where('subscriber_id = ? or visibility IN(?)',current_user.id,[Subscription.visibilities[:busy],
                                                                                                #Subscription.visibilities[:visible],
                                                                                                #Subscription.visibilities[:modify]])
    @Events_id_array = []
    @subscription.each do |subscript|
      @Events_id_array << subscript.subscribed_event_id
    end

    @events = Event.where('id in(?)',@Events_id_array)
    @subscription = Subscription.where(subscribed_event_id: params[:id]).where(subscriber_id: current_user.id).first


    @friends = User.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    @subscription = Subscription.where(subscribed_event_id: params[:id]).where(subscriber_id: current_user.id).first
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @subscription = Subscription.where(subscribed_event_id: params[:id]).where(subscriber_id: current_user.id).first
    @groups = current_user.member_of_group
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
    puts "GETTIN INTO SAVING"

    respond_to do |format|
      if @event.save

        puts "SUCCESSFUL SAVE"
        @subscription = Subscription.new(subscribed_event_id: @event.id,subscriber_id: current_user.id)
        @subscription.visibility = params[:subscription_visibility].to_i
        @subscription.save

        #@event.subscriptions << @subscription

        format.html { redirect_to @event, notice: 'Event was successfully created.' }
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

    respond_to do |format|
      if @event.update(event_params)

        if !params[:event][:visibility][:status].blank?
          @event.set_visibility(params[:event][:visibility])
        end

        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:title, :description, :start_time, :end_time)
    end
end
