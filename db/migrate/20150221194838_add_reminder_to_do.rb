class AddReminderToDo < ActiveRecord::Migration
  def change
    add_column :to_dos, :reminder_id, :integer
    add_column :reminders, :job_id, :string
  end
end
