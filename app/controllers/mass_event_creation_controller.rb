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

    if !@error.blank?
      render :index
      return
    end

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
      key = event.shift.downcase.strip

      key_error = validate_key(key, index)
      @error += key_error

      if !key_error.blank?
        index += 1
        next
      end

      event_hash = {}
      event.each do |e|
        parameter = e.split(%r{:\s*})
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
    puts "VALIDATE KEY >#{key}<"
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
    validate_number_arguments(regular_hash, line, 3, 5)
    validate_keys_of_arguments(regular_hash, line, ['title', 'description', 'start', 'end', 'to-do', :type])
  end

  def validate_request(request_hash, line)
    validate_number_arguments(request_hash, line, 4, 6)
    validate_keys_of_arguments(request_hash, line, ['title', 'description', 'start', 'end', 'participants', 'groups', :type])
  end

  def validate_to_do(to_do_hash, line)
    validate_number_arguments(to_do_hash, line, 3, 4)
    validate_keys_of_arguments(to_do_hash, line, ['title', 'description', 'priority', 'duration', :type])
  end

  def validate_slot(slot_hash, line)
    if slot_hash.count < 5
      @error += "event #{line}: wrong number of arguments. You provided #{slot_hash.count} arguments of allowed minimum of 4\n"
    end
    validate_keys_of_arguments(slot_hash, line, ['title', 'description', 'min', 'max', 'block', :type])
  end

  def validate_number_arguments(arguments, line, min, max)
    puts "VALIDATE MIN #{min} MAX #{max} ARGS: #{arguments}"
    if arguments.count < min + 1 || arguments.count > max + 1
      @error += "event #{line}: wrong number of arguments. You provided #{arguments.count} arguments of allowed range [#{min}, #{max}]\n"
    end
  end

  def validate_keys_of_arguments(arguments, line, possible_keys)
    puts "VALIDATE KEYS ARGS #{arguments} POSSIBLE #{possible_keys}"
    wrong_keys = []
    arguments.keys.each do |key|
      if !(possible_keys.include? key)
        wrong_keys << key
      end
    end
    if wrong_keys.count > 0
      @error += "event #{line}: #{'key'.pluralize(wrong_keys.count)} #{wrong_keys.join(', ')} #{wrong_keys.count == 1 ? 'is' : 'are'} invalid\n"
    end
  end

  def create_events(arguments_array)

  end

end
