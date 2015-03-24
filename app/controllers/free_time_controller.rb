class FreeTimeController < ApplicationController

  def find
    puts "*** got to FREE TIME ***"
    @users = User.where.not(:id => current_user.id)
    @groups = current_user.groups

  end

  def create
    duration = params[:duration].to_i
    users = params[:users]
    puts "**** GOT TO CREATE ****"

    if params[:request][:selected_request].nil?
      puts "**** selected nil #{params[:selected_request]} ****"
      flash[:error] = "Need to choose an event to generate the request"
      redirect_to free_time_find_path
      return
    end

    puts "** will create event ***"
    selected = params[:request][:selected_request]
    start_time = DateTime.parse(params[:request][selected][:start_time])
    event = Event.new(:title => params[:request][:title], :description => params[:request][:description], :start_time => start_time, :end_time => start_time + duration.seconds, :creator_id => current_user.id, :event_type => Event.event_types[:request])

    if event.save
      puts "**** EVENT SAVED ***"
      current_user.subscribe_to_event(event)
      request_map = RequestMap.create(:event_id => event.id)
      all_users = []
      users.map {|u| all_users << u.to_i}

      request_map.generate_requests_for_ids(all_users)
      event.request_map = request_map
      event.save

      redirect_to requests_index_path
    else
      puts "*** EVENT NOT SAVED #{event.errors.full_messages} ***"
      flash[:error] = "Event could not be saved: #{event.errors[:base]}"
      redirect_to free_time_find_path
    end

  end

  def conflict
    @duration = params[:duration].to_i
    users = params[:users]
    @start_time = DateTime.parse(params[:conflict][:start_time])
    @end_time = @start_time + @duration.seconds

    puts "*** GOT TO CONFLICT LOGIC START: #{start_time} END #{start_time + duration.seconds} USERS: #{users}"
    @events = map_user_conflict(users, start_time, duration)
  end

  def show
    @users = []
    get_users_to_search.map {|u| @users << User.find(u)}
    if @users.count == 0
      flash[:error] = "no user selected"
      redirect_to free_time_find_path
      return
    end

    @duration = params[:duration].to_i

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

    @free_times = {'params' => []}
    weekdays.each do |w|
      date = next_week_day(DateTime.now, w).beginning_of_day
      free_time = map_free_time(date + start_time.seconds, date + end_time.seconds, @users)

      free_time = eliminate_small_durations(free_time, @duration)
      puts "*** BUILDING HASH DATE: #{date} START:#{start_time} START TIME: #{date + start_time.seconds} END TIME: #{date + end_time.seconds}"
      puts "\nFREE TIME: #{free_time}\n"

      @free_times['params'] << {:start_time => date + start_time.seconds, :end_time => date + end_time.seconds, :free_times => parse_possible_start_times(free_time, @duration)}
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
    puts "*** MAP FREE TIME USER COUNT #{users.count} ****"
    if users.count == 0
      return []
    end
    start_time.second

    user_array = []
    users.map {|u| user_array << u}
    current_user = user_array.shift

    all_events = []
    while !current_user.nil?
      current_user.subscribed_events.map {|e| all_events << e}
      current_user = user_array.shift
      if current_user.nil?
        break
      end
    end
    start_time = round_second(start_time)
    end_time = round_second(end_time)

    puts "*** ALL EVENTS COUNT BEFORE QUERY FILTER #{all_events.count} ***\n"

    place_holder = []
    all_events.map {|e| place_holder << e if to_eastern_time(e.start_time) > to_eastern_time(start_time) - 5.minutes && to_eastern_time(e.end_time) < to_eastern_time(end_time + 5.minutes)}
    all_events = place_holder.sort_by {|e| e.start_time}

    free_time = []
    current_time = to_eastern_time(start_time)
    current_range = []

    puts "*** WILL CHECK ALL EVENTS COUNT #{all_events.count} ***\n"
    if all_events.empty?
      puts "*** ALL EVENTS ARE EMPTY ***\n"
      free_time << [to_eastern_time(start_time), to_eastern_time(end_time)]
      return free_time
    end

    puts "*** BEGIN OF FREE TIME ITERATION ***"
    all_events.each do |e|
      start_event = round_second(to_eastern_time(e.start_time))
      end_event = round_second(to_eastern_time(e.end_time))

      #current time hits an event block
      puts "EVENT START: #{start_event} END #{end_event} CURRENT #{current_time}"
      if contains_time(start_event, end_event, current_time)
        puts "CONTAINS"
        if current_range.count == 1
          current_range << start_event <= start_time ? end_event : start_time
          free_time << current_range
          current_range = []
        end
        current_time = end_event
      #previous event contained currents time frame
      elsif end_time < current_time
        puts "PAST EVENT, SKIP"
        next
      #open a new free range
      elsif current_time < start_event
        puts "START OF NEW FREE RUN"
        free_time << [current_time, start_event]
        current_time = end_event
      end

      #check if we did not pass
      current_time.change(:sec => 0)
      if current_time >= end_time
        puts "*** BREAK LOOP CURRENT #{current_time} END #{end_time}"
        break
      end
    end

    #corner case end iteration
    if current_time < end_time
      free_time << [current_time, to_eastern_time(end_time)]
    end

    free_time
  end

  def map_user_conflict(users, start_time, duration)
    start_time = round_second(to_eastern_time(start_time))
    end_time = start_time + duration.seconds

    user_array = []
    users.map {|u| user_array << User.find(u.to_i)}
    current_user = user_array.shift

    all_events = []
    while !current_user.nil?
      current_user.subscribed_events.map {|e| all_events << e}
      current_user = user_array.shift
      if current_user.nil?
        break
      end
    end

    place_holder = []
    all_events.each do |e|
      event_start = round_second(to_eastern_time(e.start_time))
      event_end = round_second(to_eastern_time(e.end_time))
      puts "EVENT START: #{event_start} END #{event_end}"

      #performance enhancement to reduce iterations
      if event_end < start_time
        next
      elsif event_start > end_time
        break
      end

      same_start = event_start == start_time
      overlap = event_start < end_time && event_end > start_time
      if same_start || overlap
        puts "CONFLICT"
        place_holder << e
      end

    end
    all_events = place_holder.sort_by {|e| e.start_time}
    return all_events
  end

  def eliminate_small_durations(free_time, duration)
    puts "*** ELIMINATE FREE TIME COUNT #{free_time.count} ARRAY #{free_time} ****"
    new_free_time = []
    free_time.each do |time|
      puts "ITERATION #{time} DIFF #{time[1] - time[0]}"
      if time[1] - time[0] >= duration.seconds
        new_free_time << time
      end
    end
    new_free_time
  end

  def parse_possible_start_times(free_times, duration)
    times = []
    puts "PARSING STARTS"
    free_times.each do |t|
      current_time = t.first
      while current_time + duration.seconds <= t.last
        times << current_time
        current_time += (15*60).seconds
      end
    end
    times
  end

  def contains_time(start_time, end_time, contained_time)
    puts "** CONTAINS TIME #{to_second(contained_time) >= to_second(start_time) && to_second(contained_time) < to_second(end_time)}"
    to_second(contained_time) >= to_second(start_time) && to_second(contained_time) < to_second(end_time)
  end

  def to_second(time)
    time.hour*3600 + time.min*60
  end

  def round_second(time)
    time.change(:sec => 0)
  end

  def next_week_day(date, day_week)
     date + 1.day + (((day_week-1)-date.wday)%7).day
  end

  def to_eastern_time(time)
    time.in_time_zone('Eastern Time (US & Canada)')
  end

end
