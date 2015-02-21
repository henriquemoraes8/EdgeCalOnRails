class Reminder < ActiveRecord::Base
  require 'rufus-scheduler'
  enum recurrence: [:no_recurrence, :hourly, :daily, :every_other_day, :weekly, :monthly, :yearly]

  belongs_to :to_do

  #validates_presence_of :to_do, :next_reminder_time

  after_create :schedule_next_reminder

  def schedule_next_reminder
    job = Rufus::Scheduler.singleton.schedule_at next_reminder_time do
      puts "SCHEDULED"
    end

    puts "JOB IS #{job} AND ID IS #{job.id}"

    job = Rufus::Scheduler.singleton.schedule_at next_reminder_time do
      puts "SCHEDULED2"
    end

    puts "JOB2 IS #{job} AND ID IS #{job.id}"

    self.job_id = job.id
    save
  end

  def unschedule
    Rufus::Scheduler.singleton.job(job_id).unschedule
  end

end
