class RepetitionScheme < ActiveRecord::Base
  
	enum recurrence: [:no_recurrence, :daily, :every_other_day, :weekly, :monthly, :yearly]
  
	validate :max_min_duration

	has_many :events

	### <<<< LEAVE COMMENTED OUTPUTS TO CONSOLE ALONE >>>>

	def self.recurrence_to_date_time(period)
		return 1.day if period == ToDo.recurrences[:daily] || period == "daily"
		return 2.days if period == ToDo.recurrences[:every_other_day] || period == "every_other_day"
		return 1.week if period == ToDo.recurrences[:weekly] || period == "weekly"
		return 1.month if period == ToDo.recurrences[:monthly] || period == "monthly"
		return 1.year if period == ToDo.recurrences[:yearly] || period == "yearly"
		return 0.seconds
	end

	def create_events_with_recurrence(original_event, until_time, recurrence)
		if original_event.end_time >= until_time
			return
		end

		date = original_event.end_time
		period = RepetitionScheme.recurrence_to_date_time(recurrence)
		date += period

		#puts "WILL START RECURRENCE CREATION START: #{date}, PERIOD: #{period}, DURATION: #{original_event.duration}"

		while date < until_time do
			#puts "CREATING EVENT AT DATE #{date}"
			event = Event.create(:creator_id => original_event.creator_id, :title => original_event.title,
													 :description => original_event.description, :start_time => date,
													 :end_time => date + original_event.duration, :event_type => Event.event_types[:recurrent])
			Subscription.create(subscribed_event_id: event.id,subscriber_id: original_event.creator_id)
			self.events << event
			date += period
		end

		self.events << original_event
	end

	def update_events_based_on_event(event)
		events.each do |e|
			#puts "WILL UPDATE EVENT ID #{e} TITLE #{e.title} DESCRIPTION #{e.description} TO TITLE #{event.title} AND DESC #{event.description}"
			e.title = event.title
			e.description = event.description
			e.save
		end
	end

	def time_slot_start_time_allowed_for_event(event, start_time)
		#puts "** REP TIME ALLOWED **"
		#puts "** seconds of min #{min_time_slot_duration}"
		start_allowed = event.start_time
		if start_time < event.start_time || start_time > event.end_time
			return false
		end
		while start_allowed < event.end_time
			if start_time.hour == start_allowed.hour && start_time.min == start_allowed.min
				return true
			end
			start_allowed += min_time_slot_duration
		end
		return false
	end

	def time_slot_duration_allowed(duration)
		#puts "** REP DURATION ALLOWED **"
		duration <= max_time_slot_duration
	end

	def set_title(title)
		events.each
	end

	private

	def max_min_duration
		#puts "VALIDATION MIN #{min_time_slot_duration} MAX #{max_time_slot_duration}"
		if min_time_slot_duration.nil? && max_time_slot_duration.nil?
			return true
		end
		if min_time_slot_duration > 0 || max_time_slot_duration > 0
			if min_time_slot_duration >= max_time_slot_duration || min_time_slot_duration % 5 != 0 || max_time_slot_duration % 5 != 0
				errors[:base] = "minimum and maximum durations are incompatible"
				return false
			end
		end
		true
	end

end
