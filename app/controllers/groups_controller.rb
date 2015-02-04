class GroupsController < ApplicationController
  def index
    if(params[:user_id].nil?)
        @groups = Group.where(owner_id: current_user.id)    
    else
        @groups = Group.where(owner_id: params[:user_id])
    end
    #@users = Users.all
  end

  def show
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
    #@group.owner_id = current_user.id
    @users = User.all
  end

  def create
    @group = Group.new(group_params)
    @group.owner_id = current_user.id
    if @group.save
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit

  end

  def delete
  end

  private

  def group_params
    params.require(:group).permit(:title, :description)
  end
end
