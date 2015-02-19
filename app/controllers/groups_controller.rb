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
    @users = User.where.not(id: current_user.id)
  end

  def create
    puts "PARAMS IS :#{params}"
    @group = Group.new(group_params)
    @group.owner_id = current_user.id

    if @group.save
      params[:members].keys.each do |u_id|
        if params[:members][u_id] == '1'
          puts "ADDING MEMBER ID: #{u_id}"
          @group.members << User.find(u_id)
        end
      end
      redirect_to(:action => 'index')
    else
      puts "ERROR RECORD GROUP: #{@group.errors.full_messages}"
      @users = User.where.not(id: current_user.id)
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
