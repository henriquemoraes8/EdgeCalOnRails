class ToDo < ActiveRecord::Base
  enum recurrence: [:no_recurrence, :always, :minutely, :hourly, :daily, :every_other_day, :weekly, :monthly, :yearly, :less_than_minute]

  before_update :reschedule_if_needed, :notify_event_if_needed, :stop_escalation_if_needed
  before_create :verify_next_schedule
  after_create :setup_escalation, :setup_expiration
  validate :validate_duration, :validate_expiration
  before_destroy :destroy_reminder_escalation

  belongs_to :event
  belongs_to :creator, :class_name => 'User'
  has_one :reminder


  acts_as_list scope: :creator

  def self.recurrence_to_date_time(period)
    return 0.seconds if period == ToDo.recurrences[:always] || period == 'always'
    return 1.minute if period == ToDo.recurrences[:minutely] || period == 'minutely'
    return 1.hour if period == ToDo.recurrences[:hourly] || period == 'hourly'
    return 1.day if period == ToDo.recurrences[:daily] || period == 'daily'
    return 2.days if period == ToDo.recurrences[:every_other_day] || period == 'every_other_day'
    return 1.week if period == ToDo.recurrences[:weekly] || period == 'weekly'
    return 1.month if period == ToDo.recurrences[:monthly] || period == 'monthly'
    return 1.year if period == ToDo.recurrences[:yearly] || period == 'yearly'
    return 10.seconds if period == ToDo.recurrences[:less_than_minute] || period == 'less_than_minute'
    return 0.seconds
  end

  def self.options_for_escalation_prior
    return [['never', ToDo.recurrences[:no_recurrence]],['hour before', ToDo.recurrences[:hourly]],
            ['day before', ToDo.recurrences[:daily]],['two days before', ToDo.recurrences[:every_other_day]],
            ['week before', ToDo.recurrences[:weekly]],['month before', ToDo.recurrences[:monthly]]]
  end

  def self.options_for_escalation_recurrence
    return [['never', ToDo.recurrences[:no_recurrence]],['minute',ToDo.recurrences[:minutely]],
            ['hour', ToDo.recurrences[:hourly]],['day', ToDo.recurrences[:daily]],
            ['two days', ToDo.recurrences[:every_other_day]],['week', ToDo.recurrences[:weekly]],
            ['month', ToDo.recurrences[:monthly]]]
  end

  scope :sorted, lambda {order('to_dos.position ASC')}

  def can_be_allocated(end_time)
    puts "SEE IF #{title} CAN BE ALLOCATED, EVENTNIL #{event_id.nil?}, DONE #{done}"
    expiration_not_a_problem = expiration.nil? || round_second(expiration) >= end_time
    return event_id.nil? && !done && expiration_not_a_problem
  end

  def set_reminder(params_r)

    date = DateTime.parse("#{params_r[:next_reminder_time]} Eastern Time (US & Canada)")
    puts "REMINDER TIME #{date}"

    reminder = Reminder.new(:recurrence => params_r[:recurrence], :next_reminder_time => date, :to_do_id => id)
    if reminder.save
      self.reminder = reminder
      return true
    end

    errors[:base] = "The reminder could not not be saved: #{reminder.errors[:base]}"
    return false
  end

  private

  def reschedule
    todo = ToDo.new(:title => title, :duration => duration, :description => description, :position => position, :recurrence => recurrence, :creator_id=>creator_id)
    todo.save
  end

  def verify_next_schedule
    if next_reschedule.nil? || next_reschedule < Time.now
      reset_next_schedule
    end
  end

  def reset_next_schedule
    self.next_reschedule = Time.now + ToDo.recurrence_to_date_time(recurrence)
  end

  def reschedule_if_needed
    if recurrence == 'no_recurrence' || done == false
      return
    end

    if next_reschedule <= Time.now
      reschedule
    else
      require 'rufus-scheduler'
      scheduler = Rufus::Scheduler.new

      scheduler.at next_reschedule do
        reschedule
      end
    end
  end

  def stop_escalation_if_needed
    if done && !job_id.nil?
      Rufus::Scheduler.singleton.job(job_id).unschedule
      self.job_id = nil
    end
  end

  def notify_event_if_needed
    if !event_id.nil? && done
      event.next_to_do
      event.save
    end
  end

  def validate_duration
    if duration.nil? || duration < 1 || duration%5 != 0
      errors[:base] = "a to do duration must be a multiple of 5 and greater than 0"
      return false
    end
    true
  end

  def destroy_reminder_escalation
    if !reminder.nil?
      reminder.destroy
    end
    if !job_id.nil?
      Rufus::Scheduler.singleton.job(job_id).unschedule
    end
  end

  def validate_expiration
    if !expiration.nil? && expiration <= DateTime.now
      errors[:base] = "expiration must be in the future"
      return false
    end
    true
  end

  def setup_expiration
    if expiration.nil?
      return
    end
    Rufus::Scheduler.singleton.at expiration do
      puts "EXPIRED"
      self.expiration = nil
      self.done = true
      save
    end
  end

  def setup_escalation
    if expiration.nil? || escalation_prior == ToDo.recurrences[:no_recurrence]
      return
    end
    puts "SETUP ESC EXPIRATION #{expiration}"

    if expiration - ToDo.recurrence_to_date_time(escalation_prior) < DateTime.now
      puts "AUTOMATIC ESCALATION"
      escalate
      return
    end

    puts "WILL SCHEDULE FOR #{expiration - ToDo.recurrence_to_date_time(escalation_prior)} and current time #{DateTime.now}"
    self.job_id = Rufus::Scheduler.singleton.at expiration - ToDo.recurrence_to_date_time(escalation_prior) do
      escalate
    end
    save
  end

  def escalate
    self.position = position - escalation_step < 1 ? 1 : position - escalation_step
    puts "NEW ESCALATED POS #{position} EXPIRATION #{expiration}"
    puts "MATH #{DateTime.now + ToDo.recurrence_to_date_time(escalation_recurrence)} > #{expiration}: #{DateTime.now + ToDo.recurrence_to_date_time(escalation_recurrence) > expiration}"
    if position == 1 || DateTime.now + ToDo.recurrence_to_date_time(escalation_recurrence) > expiration || escalation_recurrence == 0
      self.job_id = nil
      save
      return
    end
    self.job_id = Rufus::Scheduler.singleton.at (DateTime.now + ToDo.recurrence_to_date_time(escalation_recurrence)).to_time do
      escalate
    end
    save
  end
end