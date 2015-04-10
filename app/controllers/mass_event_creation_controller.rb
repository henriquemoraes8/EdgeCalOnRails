class MassEventCreationController < ApplicationController

  TYPE_REGULAR = 'regular'
  TYPE_TO_DO = 'to-do'
  TYPE_REQUEST = 'request'
  TYPE_SLOT = 'slot'

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
      key = event.shift.downcase

      key_error = validate_key(key, index)
      @error += key_error

      if key_error.blank?
        next
      end

      event_hash = {:type => key}
      event.each do |e|
        parameter = e.split(%r{:\s*})
        @error += validate_parameter_length(parameter, index)
        (event_hash[parameter.first] = parameter.count > 1 ? parameter.second : "") if parameter.count > 0
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
    if key != TYPE_REGULAR && key != TYPE_REQUEST && key != TYPE_SLOT && key != TYPE_TO_DO
      return "event #{line}: invalid event type\n"
    end
    ''
  end


end
