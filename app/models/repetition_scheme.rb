class RepetitionScheme < ActiveRecord::Base

	enum weekdays: { monday: 1<<1, tuesday: 1<<2, wednesday: 1<<3, thursday: 1<<4,
					 friday: 1<<5, saturday: 1<<6, sunday: 1<<7 }

	has_many :events
end
