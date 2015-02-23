class RequestsController < ApplicationController
  def index
    @request_maps = []
    current_user.get_requested_events.map {|e| @request_maps << e.request_map}
    puts "\n\nEVENTS #{current_user.get_requested_events} MAP: #{@request_map}"

    @pending_requests = current_user.requests.where(:status => Request.statuses[:pending])
    @confirmed_requests = current_user.requests.where(:status => Request.statuses[:confirmed])
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
    params[:request_map][:event][:status] = 'request'
    event = Event.new(event_params(params[:request_map]))


    if event.save
      request_map = RequestMap.create(:event_id => event.id)
      puts "**** CREATED REQUEST MAP ****"

      all_users = []
      params[:user_request].keys.each do |u|
        if params[:user_request][u] == "1"
          all_users << u.to_i
        end
      end
      params[:group_request].keys.each do |g|
        if params[:group_request][g] == "1"
          all_users << Group.find(g.to_i).all_user_ids
        end
      end
      all_users = all_users.flatten
      all_users = all_users.uniq

      puts "WILL GENERATE REQUESTS FOR IDS: #{all_users}"

      request_map.generate_requests_for_ids(all_users)

      event.request_map = request_map
      event.save
      current_user.created_events << event

      redirect_to(requests_index_path)
    else
      render(requests_new_path)
    end
  end

  def update
    @request_map = RequestMap.find(params[:id])
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
    request.status = Request.statuses[:modify]
    request.save
    flash[:notice] = "Event '#{request.request_map.event.title}' was removed"
    redirect_to(requests_index_path)
  end

  def modify

  end

  private

  def event_params(e_params)
    e_params.require(:event).permit(:title, :description, :start_time, :end_time, :event_type)
  end

end
