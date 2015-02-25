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

  helper_method :new

  def new
    @group = Group.new

    #Why is the line below commented out? -jeffday
    #@group.owner_id = current_user.id
    @users = User.where.not(id: current_user.id)
    #render('delete')
    #@membership = Membership.new()
    return @group, @users
    #render 'shared/group_form', :locals => {:group => @group, :users=@users}
  end

  def create
    puts "PARAMS IS :#{params}"
    @group = Group.new(group_params)
    @group.owner_id = current_user.id
    #@users = User.where.not(id: current_user.id)

    save_item(@group)
  end

  def save_item(group)
    if group.save
      if params[:members]
        params[:members].keys.each do |u_id|
          if params[:members][u_id] == '1' && !@group.members.exists?(u_id.to_i)
            puts "ADDING MEMBER ID: #{u_id}"
            @group.members << User.find(u_id.to_i)
          elsif params[:members][u_id] == '0' && @group.members.exists?(u_id.to_i)
            @membership=@group.memberships.where(:member_id => u_id).delete_all
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
    @group= Group.find(params[:id])
    @users = User.where.not(id: current_user.id)
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(group_params)
      save_item(@group)
      #redirect_to(:action => 'index')
    else
      render('index')
    end
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
