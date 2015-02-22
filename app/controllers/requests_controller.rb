class RequestsController < ApplicationController
  def index
    @request_maps = current_user.get_requested_events
  end

  def show
    @request_map = RequestMap.find(params[:id])
  end

  def edit
    @request_map = RequestMap.find(params[:id])
  end

  def new
    @request_map = RequestMap.new
  end

  def create

  end

  def destroy

  end

end
