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
  end

  def new
    @request_map = RequestMap.new
    @groups = current_user.groups
  end

  def create

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
