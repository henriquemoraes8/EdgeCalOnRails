class Event < ActiveRecord::Base
	enum event_type: [:regular, :to_do, :request, :recurrent, :time_slot]

	# Added by @brianbolze, @henriquemoraes -- 2/2
	belongs_to :creator, :class_name => "User"

	has_many :subscriptions, :foreign_key => 'subscribed_event_id', :dependent => :destroy
	has_many :subscribers, :through => :subscriptions

	belongs_to :repetition_scheme
	has_one :request_map, :dependent => :destroy
	has_one :to_do

	has_many :visibilities, -> { order("position ASC") }, :dependent => :delete_all

	has_many :time_slots, :dependent => :delete_all

	before_validation :check_to_do
	after_create :next_to_do

	validates_presence_of :title, :start_time, :end_time
	# validates_presence_of :creator

	def duration
		end_time - start_time
	end

	def set_visibility(params_v)
		puts "*** SAVING IN EVENT ****"
		puts params_v
		if !params_v[:group_id].blank?
			visibility = Visibility.create(:group_id => params_v[:group_id], :position => params_v[:position], :status => Visibility.statuses[params_v[:status]])
			self.visibilities << visibility
		elsif !params_v[:user_id].blank?
			visibility = Visibility.create(:user_id => params_v[:user_id], :position => params_v[:position], :status => Visibility.statuses[params_v[:status]])
			self.visibilities << visibility
		end
	end
  
  def get_visibility_for_user(user)
		visibilities.each do |v|
			if (!v.user.nil? && v.user.id == user.id) || (!v.group.nil? && v.group.contains_user_id(user.id))
				return v.status
			end
		end
  end

	def is_right_visibility_for_user(visibility, user_id)
		if event_type == 'to_do'
			return visibility == 'visible'
		elsif event_type == 'request'
			# TODO: Need to fix this potentially?
			return visibility == 'visible'
		end

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
		case event_type
			when 'to_do'
				return 'reserved for a to-do'
			when 'request'
				return 'requested event'
			else
				return 'regular event'
		end
	end

	def next_to_do
		puts "TIME NOW: #{Time.now} EVENT END: #{end_time}"
		if event_type != 'to_do'
			return
		elsif end_time < Time.now
			self.title = "allocated for to-do"
			self.description = "this event has passed and cannot be assigned a to-do"
			return
		end

		duration = start_time > Time.now && end_time < Time.now ? end_time - Time.now : end_time - start_time

		creator.to_dos.each do |t|
			if t.duration.hour*3600 + t.duration.min*60 < duration && t.can_be_allocated
				self.to_do_id = t.id
				t.event_id = id
				self.title = "allocated for to-do: #{t.title}"
				self.description = t.description
				puts "GOT A TODO AND ASSIGNED ID #{id}"
				t.save
				save
				return
			end
		end
		self.title = creator.to_dos.count == 0 ? 'there is no to-do to be assigned' : 'event too short for any to-do'
		self.description = 'no to-do could be fit for this event'
		save
	end
  
  def self.between(start_time, end_time)
      where('start_at > :lo and start_at < :up',
        :lo => Event.format_date(start_time),
        :up => Event.format_date(end_time)
      )
    end

  def self.format_date(date_time)
     Time.at(date_time.to_i).to_formatted_s(:db)
	end

	def time_slot_overlaps(time_slot)
		puts "** check time slot overlap event type #{event_type} relation #{event_type != 'time_slot'} **"
		if event_type != 'time_slot'
			return false
		end

		puts "** iteration over time slots **"
		time_slot_end = time_slot.start_time + time_slot.duration
		time_slots.each do |t|
			if t.id != time_slot.id
				t_end = t.start_time + t.duration
				factor_1 = t.start_time - time_slot_end
				factor_2 = time_slot.start_time - t_end

				exact_overlap_1 = time_slot.start_time.hour == t_end.hour && time_slot.start_time.min == t_end.min
				exact_overlap_2 = t.start_time.hour == time_slot_end.hour && t.start_time.min == time_slot_end.min

				if factor_1*factor_2 > 0 && !(exact_overlap_1 || exact_overlap_2)
					return true
				end
			end
		end

		false
	end

	private

	def check_to_do
		if event_type == 'to_do' && end_time - start_time <= 15.minutes
			errors[:base] = 'a to-do allocated event needs a minimum time frame of 15 minutes'
		end
	end

end
