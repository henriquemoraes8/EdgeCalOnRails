class TimeSlot < ActiveRecord::Base
  belongs_to :event

  #before_create :time_frame_allowed
  validate :time_frame_allowed

  def taken?
    !user_id.blank?
  end

  private

  def time_frame_allowed
    if !event.repetition_scheme.time_slot_start_time_allowed_for_event(event,start_time)
      errors[:base] = "start time does not align with a multiple of the minimum duration or does not fall within event date range"
      return false
    elsif duration.min % 5 != 0
      errors[:base] = "duration must be a multiple of 5 minutes"
      return false
    elsif !event.repetition_scheme.time_slot_duration_allowed(duration)
      errors[:base] = "duration is too big for time slot"
      return false
    elsif event.end_time < start_time + duration.hour*3600 + duration.min*60
      errors[:base] = "time slot exceeds event end time"
      return false
    elsif event.time_slot_overlaps(self)
      errors[:base] = "time slot overlaps with another scheduled slot"
      return false
    end

    true
  end

end
