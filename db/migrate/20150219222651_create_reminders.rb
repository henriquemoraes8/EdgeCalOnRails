class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.integer :recurrence, default: 0
      t.datetime :next_reminder_time
      t.integer :to_do_id

      t.timestamps null: false
    end
  end
end
