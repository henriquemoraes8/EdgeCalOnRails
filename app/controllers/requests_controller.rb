class RequestsController < ApplicationController
  def index
    @request_maps = current_user.get_requested_events
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
    puts "GOT TO CREATE, PARAMS: #{params}"

    all_users = []
    params[:users].keys.each do |u|
      if params[:users][u] == "1"
        all_users << u.to_i
      end
    end
    params[:group_request].keys.each do |g|
      if params[:group_request][g] == "1"
        all_users << Group.find(g.to_i).all_user_ids
      end
    end
    puts "RAW ARRAY: #{all_users}"
    all_users.flatten
    puts "FLATTENED #{all_users}"
    all_users.uniq
    puts "UNIQ #{all_users}"

    redirect_to(requests_index_path)
  end

  def update
    @request_map = RequestMap.find(params[:id])
  end

  def destroy
    @request_map = RequestMap.find(params[:id])
    @request_map
    flash[:notice] = "Request for Event '#{@request_map.event.title}' deleted successfully"

    redirect_to(requests_index_path)
  end

end
