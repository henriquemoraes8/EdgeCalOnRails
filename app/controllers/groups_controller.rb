class GroupsController < ApplicationController
  def index
    if(params[:user_id].nil?)
        @groups = Group.where(owner_id: current_user.id)    
    else
        @events = Group.where(owner_id: params[:user_id])
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def delete
  end

  private

  def group_params
    params.require(:group).permit(:created_at, :updated_at)
  end
end
