class Reminder < ActiveRecord::Base
  enum recurrence: [:no_recurrence, :hourly, :daily, :every_other_day, :weekly, :monthly, :yearly]

  belongs_to :to_do

  validates_presence_of :to_do, :next_reminder_time

  after_create :schedule_next_reminder

  def schedule_next_reminder

  end

end
