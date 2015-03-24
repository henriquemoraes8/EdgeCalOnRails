class RespectiveSlotToEvent < ActiveRecord::Migration
  def change
    add_column :events, :respective_slot_id, :integer
    add_column :time_slots, :slot_event_id, :integer
  end
end
