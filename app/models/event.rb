class Event < ActiveRecord::Base

	# Added by @brianbolze -- 2/2
	belongs_to :creator, :class_name => "User"

	has_many :subscriptions, :foreign_key => "subscribed_event_id"
	has_many :subscribers, :through => :subscriptions

	has_one :repetition_scheme

	validates_presence_of :title, :start_time, :end_time
	# validates_presence_of :creator



end
