class MassEventCreationController < ApplicationController

  TYPE_REGULAR = 'regular'
  TYPE_TO_DO = 'to-do'
  TYPE_REQUEST = 'request'
  TYPE_SLOT = 'slot'
  ALL_TYPES = [TYPE_REGULAR, TYPE_TO_DO, TYPE_REQUEST, TYPE_SLOT]

  def index
    @users = User.where.not(:id => current_user.id)
    @groups = current_user.groups
  end

  def help
  end

  def show
  end

  def process_events
    @users = User.where.not(:id => current_user.id)
    @groups = current_user.groups
    @text = params[:events]
    @error = ""

    parsed_params = parse_text
    puts "PARSED PARAMS #{parsed_params}"

    if !@error.blank?
      render :index
      return
    end

    validate_input(parsed_params)

    if !@error.blank?
      render :index
      return
    end

    created_events = create_events(parsed_params)

    puts "CREATED EVENTS IS #{created_events}"

    if !@error.blank?
      created_events.map {|e| e.destroy}
      render :index
      return
    end

    created_events.map {|e| e.destroy}

    render :index
  end

  private

  def parse_text
    split = []
    @text.split(%r{\n\s*}).map {|s| split << s.strip}
    puts "\nCOUNT #{split.count} SPLIT: #{split}"

    event_array = []
    index = 1
    split.each do |s|
      event = s.split(%r{;\s*})

      if event.count == 0
        index += 1
        next
      end

      key = event.shift.downcase.strip

      key_error = validate_key(key, index)
      @error += key_error

      if !key_error.blank?
        index += 1
        next
      end

      event_hash = {}
      event.each do |e|
        parameter = e.split(%r{:\s*}, 2)
        @error += validate_parameter_length(parameter, index)
        (event_hash[parameter.first.downcase.strip] = parameter.count > 1 ? parameter.second.strip : "") if parameter.count > 0
      end
      event_hash[:type] = key

      event_array << event_hash
      index += 1
    end

    puts "EVENT ARRAY COUNT: #{event_array.count} ARRAY:\n#{event_array}"

    event_array
  end

  def validate_parameter_length(param_array, line)
    if param_array.count > 2
      return "event #{line}: syntax error on #{param_array.join(': ')}\n"
    end
    ''
  end

  def validate_key(key, line)
    #puts "VALIDATE KEY >#{key}<"
    if !(ALL_TYPES.include? key)
      return "event #{line}: invalid event type\n"
    end
    ''
  end

  def validate_input(input_array)
    line = 1
    input_array.each do |e|
      case e[:type]
        when TYPE_REGULAR
          validate_regular(e, line)
        when TYPE_REQUEST
          validate_request(e, line)
        when TYPE_TO_DO
          validate_to_do(e, line)
        when TYPE_SLOT
          validate_slot(e, line)
        else
      end
      line += 1
    end
  end

  def validate_regular(regular_hash, line)
    validate_mandatory_arguments(regular_hash, line,['title', 'start', 'end'])
    validate_keys_of_arguments(regular_hash, line, ['title', 'description', 'start', 'end', 'to-do', :type])
  end

  def validate_request(request_hash, line)
    validate_mandatory_arguments(request_hash, line, ['title', 'start', 'end'])
    validate_keys_of_arguments(request_hash, line, ['title', 'description', 'start', 'end', 'participants', 'groups', :type])
    if !(request_hash.keys.include? 'participants') && !(request_hash.keys.include? 'groups')
      @error += "event #{line}: must have either participants or groups"
    end
  end

  def validate_to_do(to_do_hash, line)
    validate_mandatory_arguments(to_do_hash, line, ['title', 'position', 'duration'])
    validate_keys_of_arguments(to_do_hash, line, ['title', 'description', 'position', 'duration', :type])
  end

  def validate_slot(slot_hash, line)
    validate_mandatory_arguments(slot_hash, line, ['title', 'min', 'max', 'block'])
    validate_keys_of_arguments(slot_hash, line, ['title', 'description', 'min', 'max', 'block', :type])
  end

  def validate_mandatory_arguments(arguments, line, mandatory_keys)
    missing_args = mandatory_keys - arguments.keys
    if missing_args.count > 0
      @error += "event #{line}: missing #{'argument'.pluralize(missing_args.count)} #{missing_args.join(', ')}\n"
    end
  end

  def validate_keys_of_arguments(arguments, line, possible_keys)
    #puts "VALIDATE KEYS ARGS #{arguments} POSSIBLE #{possible_keys}"
    wrong_keys = arguments.keys - possible_keys
    if wrong_keys.count > 0
      @error += "event #{line}: #{'key'.pluralize(wrong_keys.count)} #{wrong_keys.join(', ')} #{wrong_keys.count == 1 ? 'is' : 'are'} invalid\n"
    end
  end

  def create_events(arguments_array)
    events = []
    line = 1
    arguments_array.each do |e|
      value_error = validate_values(e, line)
      if !value_error.empty?
        line += 1
        @error += value_error
        next
      end

      puts "POS ARGUMENT WITH VALUES: #{e}\n"

      case e[:type]
        when TYPE_REGULAR
          events << create_regular_event(e)
        when TYPE_TO_DO
          events << create_to_do_event(e)
        when TYPE_REQUEST
          events << create_request_event(e)
        when TYPE_SLOT
          events << create_slot_event(e)
      end
      line += 1
    end
    events
  end

  def create_regular_event(args)
    puts "ARGS REGULAR #{args}"
    event = Event.new(:title => args['title'], :description => args['description'],
    :start_time => args['start'], :end_time => args['end'], :creator_id => current_user.id)
    event.event_type = Event.event_types[(args.include? 'to-do') ? :to_do : :regular]
    if !event.save
      @error += "Error creating event #{event.title}. #{event.errors[:base]}"
    end
    event
  end

  def create_to_do_event(args)
    puts "ARGS TODO #{args}"
    to_do = ToDo.new(:title => args['title'], :description => args['description'],
    :position => args['position'], :duration => Time.now.beginning_of_day + args['duration']*60, :creator_id => current_user.id)
    if !to_do.save
      @error += "Error creating to do #{to_do.title}. #{to_do.errors[:base]}"
    end
    to_do
  end

  def create_request_event(args)
    puts "ARGS REQUEST #{args}"
    event = Event.new(:title => args['title'], :description => args['description'],
                      :start_time => args['start'], :end_time => args['end'],
                      :creator_id => current_user.id, :event_type => Event.event_types[:request])

    if event.save
      request_map = RequestMap.create(:event_id => event.id)
      all_users = (args.include? 'participants') ? [] : args['participants']

      if args.include? 'groups'
        args['groups'].each do |g|
          group = Group.find_by_id(g)
          if group.nil?
            @error += "Error creating request #{event.title} group id #{g} does not exist"
            return event
          else
            all_users << group.all_user_ids
          end
        end
      end

      all_users = all_users.flatten.uniq
      all_users.each do |u|
        if User.find_by_id(u).nil?
          @error += "Error creating request #{event.title} user id #{g} does not exist"
          return event
        end
      end

      request_map.generate_requests_for_ids(all_users)
      event.request_map_id = request_map.id
      event.save
      current_user.created_events << event
    else
      @error += "Error creating request #{event.title}. #{event.errors[:base]}"
    end
    event
  end

  def create_slot_event(args)
    puts "ARGS SLOT #{args}"
    repetition = RepetitionScheme.create(:min_time_slot_duration => args['min'], :max_time_slot_duration => args['max'])
    args['block'].each do |b|
      event = Event.new(:title => args['title'], :description => args['description'],
      :event_type => Event.event_types[:time_slot_block])
    end
  end

  def validate_values(values, line)
    value_error = ""
    if values['title'].blank?
      value_error += "event #{line}: title needs to be filled\n"
    end

    value_error += validate_date(values, 'start', line)
    value_error += validate_date(values, 'end', line)

    if values.keys.include? 'position' && !is_int?(values['position'])
      value_error += "event #{line}: position is not an integer\n"
    else
      values['position'] = values['position'].to_i
    end

    value_error += validate_duration(values, 'duration', line)
    value_error += validate_duration(values, 'min', line)
    value_error += validate_duration(values, 'max', line)

    if values.keys.include? 'block'
      date_times = values['block'].split
      puts "DATE TIMES IS #{date_times}"
      parsed_dates = []
      if date_times.count != 3
        value_error += "event #{line}: block needs a date, a start, and end time\n"
      else
        date_times.each do |d|
          begin
            d.to_datetime
          rescue
            value_error += "event #{line}: block has incorrect date time format\n"
            break
          end
          parsed_dates << d.to_datetime
        end
        values['block'] = parsed_dates
      end
    end

    value_error
  end

  def validate_duration(args, key, line)
    duration_error = ''
    if !(args.keys.include? key)
      return duration_error
    end

    duration = args[key]
    if !duration.empty? && !is_int?(duration)
      duration_error += "event #{line}: #{key} is not an integer\n"
    elsif !duration.empty? && duration.to_i % 5 != 0
      duration_error += "event #{line}: #{key} is not a multiple of 5\n"
    else
      args[key] = duration.to_i
    end
    duration_error
  end

  def validate_date(args, key, line)
    date_error = ''
    if !(args.keys.include? key)
      return date_error
    end

    if args[key].empty?
      date_error += "event #{line}: #{key} in incorrect format\n"
    else
      begin
        args[key].to_datetime
      rescue
        date_error += "event #{line}: #{key} in incorrect format\n"
        return date_error
      end
      args[key] = args[key].to_datetime
    end

    date_error
  end

  def is_int?(integer)
   !!(integer =~ /\A[-+]?[0-9]+\z/)
  end

  def validate_id_list(args, line)
    id_error = ''
    if !(args.keys.include? 'participants') && !(args.keys.include? 'groups')
      return id_error
    end

    if args.keys.include? 'participants'
      new_participants = []
      list = args['participants'].split.strip
      list.map {|n| new_participants << n.to_i if is_int?(n)}
      if list.count != new_participants.count
        id_error += "event #{line}: participants must be a comma separated list of integers"
      else
        args['participants'] = new_participants
      end
    end

    if args.keys.include? 'groups'
      new_participants = []
      list = args['groups'].split.strip
      list.map {|n| new_participants << n.to_i if is_int?(n)}
      if list.count != new_participants.count
        id_error += "event #{line}: groups must be a comma separated list of integers"
      else
        args['groups'] = new_participants
      end
    end

    id_error
  end

end
