class Event < ActiveRecord::Base
	enum type: [:regular, :to_do, :request]

	# Added by @brianbolze, @henriquemoraes -- 2/2
	belongs_to :creator, :class_name => "User"

	has_many :subscriptions, :dependent => :delete_all
	has_many :subscribers, :through => :subscriptions

	has_one :repetition_scheme

	has_many :visibilities, -> { order("position ASC") }, :dependent => :delete_all

	validates_presence_of :title, :start_time, :end_time
	# validates_presence_of :creator

	def set_visibility(params_v)
		puts "*** SAVING IN EVENT ****"
		puts params_v
		if !params_v[:group_id].blank?
			visibility = Visibility.create(:group_id => params_v[:group_id], :position => params_v[:position], :status => Visibility.statuses[params_v[:status]])
			self.visibilities << visibility
		elsif !params_v[:user_id].blank?
			visibility = Visibility.create(:group_id => params_v[:user_id], :position => params_v[:position], :status => Visibility.statuses[params_v[:status]])
			self.visibilities << visibility
		end
	end

	def is_right_visibility_for_user(visibility, user_id)
		visibilities.each do |v|
			puts "CHECKING VISIBILITY STATUS #{v.status} WITH POSITION #{v.position}"
			if (!v.user.nil? && v.user.id == user_id) || (!v.group.nil? && v.group.contains_user_id(user_id))
				"TRUE CASE FOR USER #{(!v.user.nil? && v.user.id == user_id)} OR GROUP #{(!v.group.nil? && v.group.contains_user_id(user_id))}"
				return v.status == visibility
			end
		end
		#if no match, default to visible
		return visibility == "visible"
	end

	def humanize_type
		case type
			when 'regular'
				return 'regular event'
			when 'to_do'
				return 'allocated for a to-do'
			when 'request'
				return 'requested event'
		end
		return ''
	end

end
