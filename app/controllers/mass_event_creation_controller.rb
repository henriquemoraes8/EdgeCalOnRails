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

      if key_error.blank?
        index += 1
        next
      end

      event_hash = {:type => key}
      event.each do |e|
        parameter = e.split(%r{:\s*})
        @error += validate_parameter_length(parameter, index)
        (event_hash[parameter.first.downcase.strip] = parameter.count > 1 ? parameter.second.strip : "") if parameter.count > 0
      end

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
    end
  end

  def validate_regular(regular_hash, line)
    validate_number_arguments(regular_hash, line, 3, 5)
    validate_keys(regular_hash, line, ['title', 'description', 'start', 'end', 'to-do'])
  end

  def validate_request(request_hash, line)
    validate_number_arguments(request_hash, line, 4, 6)
    validate_keys(regular_hash, line, ['title', 'description', 'start', 'end', 'to-do'])
  end

  def validate_to_do(to_do_hash, line)
    validate_number_arguments(to_do_hash, line, 3, 4)
    validate_keys(to_do_hash, line, ['title', 'description', 'start', 'end', 'to-do'])
  end

  def validate_slot(slot_hash, line)
    if arguments.count < 6
      @error += "event #{line}: wrong number of arguments. You provided #{arguments.count} arguments of allowed minimum of 6"
    end
    validate_keys(regular_hash, line, ['title', 'description', 'start', 'end', 'to-do'])
  end

  def validate_number_arguments(arguments, min, max, line)
    if arguments.count < min + 1 || arguments.count > max + 1
      @error += "event #{line}: wrong number of arguments. You provided #{arguments.count} arguments of allowed range [#{min}, #{max}]"
    end
  end

  def validate_keys(arguments, line, possible_keys)
    arguments.each do |key, value|
      if !(possible_keys.include? key)
        @error += "event #{line}: key #{key} not valid"
      end
    end
  end

end
