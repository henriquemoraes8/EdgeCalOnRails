class Subscription < ActiveRecord::Base

  enum email_notification_time_unit: [ :minutes, :hours, :days ]

  belongs_to :subscriber, class_name: "User"
  belongs_to :subscribed_event, class_name: "Event"
  has_one :reminder

  #validates :subscriber, presence: true
  #validates :subscribed_event, presence: true

  validates :subscriber, presence: true
  validates :subscribed_event, presence: true

  def set_reminder(params_r)
    puts "*** WILL CREATE REMINDER WITH PARAMS: #{params_r}"
    date = DateTime.parse("#{params_r[:next_reminder_time]} Eastern Time (US & Canada)")
    puts "DATE IS #{date}"
    reminder = Reminder.new(:next_reminder_time => date, :subscription_id => id)
    if reminder.save
      self.reminder = reminder
      return true
    end

    errors[:base] = "The reminder could not not be saved: #{reminder.errors[:base]}"
    return false
  end
end
