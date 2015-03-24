class FreeTimeController < ApplicationController

  def find
    puts "*** got to FREE TIME ***"
    @users = User.where.not(:id => current_user.id)
    @groups = current_user.groups

  end

  def show
    @users = []
    get_users_to_search.map {|u| @users << User.find(u)}
    if @users.count == 0
      flash[:error] = "no user selected"
      redirect_to free_time_find_path
      return
    end

    duration = params[:duration].to_i

    weekdays = get_weekday_indexes
    if weekdays.count == 0
      flash[:error] = "no weekday selected"
      redirect_to free_time_find_path
      return
    end

    start_time = params[:start_time].to_i
    end_time = params[:end_time].to_i
    if end_time <= start_time
      flash[:error] = "start time must be before end time"
      redirect_to free_time_find_path
      return
    end

  end

  private

  def get_users_to_search
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
    all_users
  end

  def get_weekday_indexes
    weekdays = []
    params[:weekday].keys.each do |w|
      if params[:weekday][w] == "1"
        weekdays << w.to_i
      end
    end
    weekdays
  end

end
