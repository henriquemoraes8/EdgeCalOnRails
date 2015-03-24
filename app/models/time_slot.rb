class TimeSlot < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  has_one :slot_event, :class_name => 'Event', :foreign_key => 'respective_slot_id', :dependent => :destroy

  validate :time_frame_allowed

  after_create :generate_event_slot

  def taken?
    !user_id.blank?
  end

  private

  def time_frame_allowed
    if user_id && !event.time_slots.where(:user_id => user_id).empty?
      errors[:base] = "user already has a time slot for this event"
      return false
    elsif !event.repetition_scheme.time_slot_start_time_allowed_for_event(event,start_time)
      errors[:base] = "start time does not align with a multiple of the minimum duration or does not fall within event date range"
      return false
    elsif (duration/60) % 5 != 0
      errors[:base] = "duration must be a multiple of 5 minutes"
      return false
    elsif !event.repetition_scheme.time_slot_duration_allowed(duration)
      errors[:base] = "duration is too big for time slot"
      return false
    elsif event.end_time < start_time + duration
      errors[:base] = "time slot exceeds event end time"
      return false
    elsif event.time_slot_overlaps(self)
      errors[:base] = "time slot overlaps with another scheduled slot"
      return false
    end

    true
  end

  def generate_event_slot
    event_slot = Event.create(:title => 'slot', :start_time => start_time, :end_time => start_time + duration, :respective_slot_id => id, :event_type => Event.event_types[:time_slot])
    puts "CREATED EVENT ID #{event_slot.id} SLOT_ID #{event_slot.respective_slot_id}"
    self.slot_event = event_slot
    puts "ASSIGNED TO SLOT"
    user.subscribe_to_event(event_slot)
    puts "SUBSCRIBED TO USER 1"
    event.creator.subscribe_to_event(event_slot)
    puts "SUBSCRIBED TO USER 2"

    self.save
  end

end
