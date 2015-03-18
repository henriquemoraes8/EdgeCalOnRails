class CreateTimeSlots < ActiveRecord::Migration
  def change
    create_table :time_slots do |t|
      t.integer :user_id
      t.integer :event_id, null: false
      t.datetime :start_time
      t.time :duration
      t.timestamps null: false
    end
  end
end
