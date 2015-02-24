class ReminderForSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :reminder_id, :integer
    add_column :reminders, :subscription_id, :integer
  end
end
