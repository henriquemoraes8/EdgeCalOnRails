class ToDo < ActiveRecord::Base
  enum recurrence: [:no_recurrence, :always, :hourly, :daily, :every_other_day, :weekly, :monthly, :yearly]

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
    return 0.seconds
  end

  scope :sorted, lambda {order('to_dos.position ASC')}

end
