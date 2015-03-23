class RequestsController < ApplicationController
  
  ################################################################
  # The requests controller deals with event creation requests,
  # which can be sent by users to either other users or groups of
  # users.  The event requests can be confirmed, declined, or a 
  # user can request to be removed from an event.
  ################################################################

  def index
    @request_maps = []
    current_user.get_requested_events.map {|e| @request_maps << e.request_map}
    puts "\n\nEVENTS #{current_user.get_requested_events} MAP: #{@request_map}"

    @pending_requests = current_user.requests.where(:status => Request.statuses[:pending])
    @confirmed_requests = current_user.requests.where('status = ? OR status = ?', Request.statuses[:confirmed], Request.statuses[:modify])
    @pending_modifications = current_user.requests.where(:status => Request.statuses[:modify])

    @modification_requests = []
    @request_maps.each do |m|
      puts "LOOKING INTO REQUEST MAP ID #{m.id}"
      puts "RESULT OF MOD QUERY #{m.requests.where(:status => Request.statuses[:modify])}"

      m.requests.where(:status => Request.statuses[:modify]).map {|r| @modification_requests << r}
    end

    @modification_requests.flatten
    puts "MODIFICATION SIZE #{@modification_requests.size} LOOK #{@modification_requests}"

  end

  def show
    @request_map = RequestMap.find(params[:id])
  end

  def edit
    @request_map = RequestMap.find(params[:id])
    @groups = current_user.groups
    @users = User.where.not(:id => current_user.id)
  end

  def new
    @request_map = RequestMap.new
    @groups = current_user.groups
    @users = User.where.not(:id => current_user.id)
  end

  def create
    params[:request_map][:event][:event_type] = 'request'

    event = Event.new(event_params(params[:request_map]))

    if event.save
      current_user.subscribe_to_event(event)
      request_map = RequestMap.create(:event_id => event.id)
      puts "**** CREATED REQUEST MAP ****"

      all_users = []

      if !params[:user_request].blank?
        params[:user_request].keys.each do |u|
          if params[:user_request][u] == "1"
            all_users << u.to_i
          end
        end
      end

      if !params[:group_request].blank?
        params[:group_request].keys.each do |g|
          if params[:group_request][g] == "1"
            all_users << Group.find(g.to_i).all_user_ids
          end
        end
      end
      all_users = all_users.flatten
      all_users = all_users.uniq

      puts "WILL GENERATE REQUESTS FOR IDS: #{all_users}"

      request_map.generate_requests_for_ids(all_users)

      event.request_map = request_map
      event.save
      puts "NEW EVENT ID: #{event.id}"
      current_user.created_events << event

      redirect_to(requests_index_path)
    else
      render(requests_new_path)
    end
  end

  def update
    @request_map = RequestMap.find(params[:id])
    @request_map.update_attributes(request_params)
      # save_item(@request_map)
      redirect_to(:action => 'index')
    else
      render('index')
    end
  end

  def destroy
    @request_map = RequestMap.find(params[:id])
    @request_map.event.destroy
    flash[:notice] = "Request for Event '#{@request_map.event.title}' deleted successfully"

    redirect_to(requests_index_path)
  end

  def accept
    request = Request.find(params[:id])
    request.status = Request.statuses[:confirmed]
    request.save
    current_user.subscribe_to_event(request.request_map.event)
    flash[:notice] = "Event '#{request.request_map.event.title}' confirmed"
    redirect_to(requests_index_path)
  end

  def decline
    request = Request.find(params[:id])
    request.status = Request.statuses[:declined]
    request.save
    flash[:notice] = "Event '#{request.request_map.event.title}' was declined"
    redirect_to(requests_index_path)
  end

  def remove
    request = Request.find(params[:id])
    request.status = Request.statuses[:removed]
    request.save
    current_user.unsubscribe_to_event(request.request_map.event)
    flash[:notice] = "Event '#{request.request_map.event.title}' was removed"
    redirect_to(requests_index_path)
  end

  def modify
    @request = Request.find(params[:id])
  end

  def send_modification_request
    @request = Request.find(params[:id])
    @request.assign_attributes(request_params)
    @request.status = Request.statuses[:modify]
    @request.save
    redirect_to requests_index_path
  end

  def accept_modification
    @request = Request.find(params[:id])
    event = @request.request_map.event
    event.title = @request.title
    event.description = @request.description
    event.start_time = @request.start_time
    event.end_time = @request.end_time

    if event.save
      @request.request_map.requests.map { |r| r.status = Request.statuses[:pending];
        r.save;
        r.user.unsubscribe_to_event(r.request_map.event)}
      flash[:notice] = "Event '#{event.title}' modified by #{@request.user.email}"
      redirect_to requests_index_path
    else
      render 'modify'
    end
  end

  def decline_modification
    request = Request.find(params[:id])
    request.status = Request.statuses[:confirmed]
    request.save
    redirect_to requests_index_path
  end

  private

  def event_params(e_params)
    e_params.require(:event).permit(:title, :description, :start_time, :end_time, :event_type)
  end

  def request_params
    params.require(:request).permit(:title, :description, :start_time, :end_time)
  end

end
