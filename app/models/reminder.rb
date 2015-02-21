class Reminder < ActiveRecord::Base
  require 'rufus-scheduler'
  enum recurrence: [:no_recurrence, :hourly, :daily, :every_other_day, :weekly, :monthly, :yearly]

  belongs_to :to_do

  validates_presence_of :to_do, :next_reminder_time

  after_create :schedule_reminder
  before_destroy :unschedule

  def schedule_reminder
    if recurrence == 'no_recurrence'
      self.job_id = Rufus::Scheduler.singleton.at next_reminder_time do
        NotificationMailer.to_do_reminder_email(to_do.creator, to_do).deliver
      end
    else
      self.job_id = Rufus::Scheduler.singleton.every Reminder.recurrence_to_date_time(recurrence), :first_at => next_reminder_time do
        NotificationMailer.to_do_reminder_email(to_do.creator, to_do).deliver
      end
    end

    save
  end

  def unschedule_and_save
    Rufus::Scheduler.singleton.job(job_id).unschedule
    self.job_id = nil
    save
  end

  def unschedule
    Rufus::Scheduler.singleton.job(job_id).unschedule
  end

  def self.recurrence_to_date_time(period)
    return 10.seconds if period == Reminder.recurrences[:hourly] || period == "hourly"
    return 1.day if period == Reminder.recurrences[:daily] || period == "daily"
    return 2.days if period == Reminder.recurrences[:every_other_day] || period == "every_other_day"
    return 1.week if period == Reminder.recurrences[:weekly] || period == "weekly"
    return 1.month if period == Reminder.recurrences[:monthly] || period == "monthly"
    return 1.year if period == Reminder.recurrences[:yearly] || period == "yearly"
    return 10.seconds if period == Reminder.recurrences[:less_than_minute] || period == "less_than_minute"
  end

end
