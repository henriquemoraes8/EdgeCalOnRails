class GroupsController < ApplicationController

  ################################################################
  # The groups controller handles all user interaction with groups,
  # which help simplify the process of adding large groups of users
  # to different events and changing visibilities.
  ################################################################

  def index
    if(params[:user_id].nil?)
      @groups = Group.where(owner_id: current_user.id)    
    else
      @groups = Group.where(owner_id: params[:user_id])
    end
  end

  def show
    @group = Group.find(params[:id])
  end

  helper_method :new

  def new
    @group = Group.new

    #Why is the line below commented out? -jeffday
    #@group.owner_id = current_user.id
    @users = User.where.not(id: current_user.id)
    #render('delete')
    #@membership = Membership.new()
    return @group, @users
  end

  def create
    puts "PARAMS IS :#{params}"
    @group = Group.new(group_params)
    @group.owner_id = current_user.id

    if @group.save
      if params[:members]
        params[:members].keys.each do |u_id|
          if params[:members][u_id] == '1'
            puts "ADDING MEMBER ID: #{u_id}"
            @group.members << User.find(u_id)
          end
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

  helper_method :delete

  def delete
    @group = Group.find(params[:id])
  end

  helper_method :destroy

  def destroy
    @group=Group.find(params[:id]).destroy
    redirect_to(:action => 'index')
  end

  private

  def group_params
    params.require(:group).permit(:title, :description)
  end
end
