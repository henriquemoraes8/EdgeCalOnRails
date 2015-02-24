class Reminder < ActiveRecord::Base
  require 'rufus-scheduler'
  enum recurrence: [:no_recurrence, :hourly, :daily, :every_other_day, :weekly, :monthly, :yearly]

  belongs_to :to_do
  belongs_to :subscription

  #validates_presence_of :to_do, :next_reminder_time

  after_create :schedule_reminder
  before_destroy :unschedule
  before_create :start_time_makes_sense

  def schedule_reminder
    puts "GOT TO SCHEDULE REMINDER, TODO: #{to_do_id}, SUBSCRIPTION #{subscription_id}"
    if !to_do_id.nil?
      to_do_reminder
    elsif !subscription_id.nil?
      subscription_reminder
    end
  end

  def unschedule_and_save
    unschedule
    self.job_id = nil
    save
  end

  def unschedule
    if !Rufus::Scheduler.singleton.job(job_id).nil?
      Rufus::Scheduler.singleton.job(job_id).unschedule
    end
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

  private

  def start_time_makes_sense
    puts "TIME MAKES SENSE REMINDER #{next_reminder_time.in_time_zone("Eastern Time (US & Canada)")}, NOW #{Time.now}"
    self.next_reminder_time = next_reminder_time.in_time_zone("Eastern Time (US & Canada)")
    if next_reminder_time.strftime("%Y-%d-%m %H:%M:%S %Z") < Time.now.strftime("%Y-%d-%m %H:%M:%S %Z")
      errors[:base] = 'the reminder notification time has already passed'
      return false
    end
    true
  end

  def to_do_reminder
    if recurrence == 'no_recurrence'
      puts "NO RECURR NEXT TIME #{next_reminder_time}"
      self.job_id = Rufus::Scheduler.singleton.at next_reminder_time do
        puts "GONNA SEND"
        NotificationMailer.to_do_reminder_email(to_do.creator, to_do).deliver_now
      end
    else
      self.job_id = Rufus::Scheduler.singleton.every Reminder.recurrence_to_date_time(recurrence), :first_at => next_reminder_time do
        NotificationMailer.to_do_reminder_email(to_do.creator, to_do).deliver_now
      end
    end
    save
  end

  def subscription_reminder
    puts "SUBSCRIPTION REMINDER NEXT TIME #{next_reminder_time}"
    self.job_id = Rufus::Scheduler.singleton.at next_reminder_time do
      puts "GONNA SEND"
      NotificationMailer.subscription_reminder_email(subscription.subscriber, subscription).deliver_now
    end
  end

end
