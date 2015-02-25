class RepetitionScheme < ActiveRecord::Base
	enum recurrence: [:no_recurrence, :daily, :every_other_day, :weekly, :monthly, :yearly]

	has_many :events

	def self.recurrence_to_date_time(period)
		return 1.day if period == ToDo.recurrences[:daily] || period == "daily"
		return 2.days if period == ToDo.recurrences[:every_other_day] || period == "every_other_day"
		return 1.week if period == ToDo.recurrences[:weekly] || period == "weekly"
		return 1.month if period == ToDo.recurrences[:monthly] || period == "monthly"
		return 1.year if period == ToDo.recurrences[:yearly] || period == "yearly"
		return 0.seconds
	end

	def create_events_with_recurrence(start_time, end_time, recurrence)
		
	end

end
