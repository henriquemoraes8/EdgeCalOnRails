class FreeTimeController < ApplicationController

  def find
    puts "*** got to FREE TIME ***"
    @users = User.where.not(:id => current_user.id)
    @groups = current_user.groups
    @allowed_durations = generate_allowed_durations

  end

  def show
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
    return all_users
  end

  def generate_allowed_durations
    duration = 15*60
    allowed = []
    while duration <= 4*3600
      allowed << [Time.at(duration).utc.strftime("%H:%M"), duration]
      duration += 15*60
    end
    return allowed
  end

end
