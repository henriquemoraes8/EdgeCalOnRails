class ToDo < ActiveRecord::Base
  enum recurrence: [:no_recurrence, :always, :hourly, :daily, :every_other_day, :weekly, :monthly, :yearly, :less_than_minute]

  before_update :reschedule_if_needed
  before_create :verify_next_schedule

  belongs_to :event
  belongs_to :creator, :class_name => "User"

  acts_as_list scope: :creator

  def self.recurrence_to_date_time(period)
    return 0.seconds if period == ToDo.recurrences[:always] || period == "always"
    return 1.hour if period == ToDo.recurrences[:hourly] || period == "hourly"
    return 1.day if period == ToDo.recurrences[:daily] || period == "daily"
    return 2.days if period == ToDo.recurrences[:every_other_day] || period == "every_other_day"
    return 1.week if period == ToDo.recurrences[:weekly] || period == "weekly"
    return 1.month if period == ToDo.recurrences[:monthly] || period == "monthly"
    return 1.year if period == ToDo.recurrences[:yearly] || period == "yearly"
    return 10.seconds if period == ToDo.recurrences[:less_than_minute] || period == "less_than_minute"
    return 0.seconds
  end

  scope :sorted, lambda {order('to_dos.position ASC')}

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

end
