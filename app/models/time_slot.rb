class TimeSlot < ActiveRecord::Base
  belongs_to :event

  def taken?
    !user_id.blank?
  end



end
