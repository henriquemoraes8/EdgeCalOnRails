class Event < ActiveRecord::Base

	# Added by @brianbolze -- 2/2
	belongs_to :creator, :class_name => "User"

	has_many :subscriptions, :foreign_key => "subscribed_event_id"
	has_many :subscribers, :through => :subscriptions

	has_one :repetition_scheme

	has_many :visibilities

	validates_presence_of :title, :start_time, :end_time
	# validates_presence_of :creator

	def set_visibility(params_v)
		puts "*** SAVING IN EVENT ****"
		puts params_v
		if !params_v[:group_id].blank?
			visibility = Visibility.create(:group_id => params_v[:group_id], :position => params_v[:position], :status => Visibility.visibility_statuses[params_v[:status]])
			self.visibilities << visibility
		elsif !params_v[:user_id].blank?
			visibility = Visibility.create(:group_id => params_v[:user_id], :position => params_v[:position], :status => Visibility.visibility_statuses[params_v[:status]])
			self.visibilities << visibility
		end
	end

end
