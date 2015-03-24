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

    @free_times = {}
    weekdays.each do |w|
      date = next_week_day(DateTime.now, w).beginning_of_day
      free_time = map_free_time(date + start_time, date + end_time, @users)
      free_time = eliminate_small_durations(free_time, duration)
      puts "*** BUILDING HASH START TIME: #{date + start_tim} END TIME: #{date + end_time} FREE TIME COUNT: #{free_time.count}"

      @free_times << {:start_time => date + start_time, :end_time => date + end_time, :free_times => free_time}
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

  def map_free_time(start_time, end_time, users)
    if users.count == 0
      return []
    end
    start_time.second

    current_user = users.shift
    all_events = current_user.subscribed_events
    while !current_user.nil?
      current_user = users.shift
      current_user.subscribed_events.map |e| all_events << e
    end
    round_second(start_time)
    round_second(end_time)

    all_events = all_events.where('start_time > ? and end_time < ?',start_time - 5.minutes, end_time + 5.minutes).order(:start_time)
    step = 15*60
    free_time = []
    current_time = start_time
    current_range = []

    if all_events.empty?
      free_time << [start_time, end_time]
      return free_time
    end

    all_events.each do |e|
      #current time hits an event block
      if contains_time(e.start_time, e.end_time, current_time)
        if current_range.count == 1
          current_range << round_second(e.start_time <= start_time ? e.start_time : start_time)
          free_time << current_range
          current_range = []
        end
        current_time = round_second(e.end_time)
      #previous event contained currents time frame
      elsif end_time < current_time
        next
      #open a new free range
      elsif current_time < round_second(e.start_time) && free_time.count == 0
        free_time << current_time
        current_time += step
      else
        current_time += step
      end

      #check if we did not pass
      current_time.change(:sec => 0)
      if current_time >= end_time
        break
      end
    end

    #corner case end iteration
    if current_time < end_time
      free_time << [current_time, end_time]
    end

    free_time
  end

  def eliminate_small_durations(free_time, duration)
    new_free_time = []
    free_time.each do |time|
      if time[1] - time[0] >= duration
        new_free_time << time
      end
    end
    new_free_time
  end

  def contains_time(start_time, end_time, contained_time)
    to_second(contained_time) >= to_second(start_time) && to_second(contained_time) < to_second(end_time)
  end

  def to_second(time)
    time.hour*3600 + time.min*60
  end

  def round_second(time)
    time.change(:sec => 0)
  end

  def next_week_day(date, day_week)
     1.day + (((day_week-1)-date.wday)%7).day
  end

end
