class AddReminderToDo < ActiveRecord::Migration
  def change
    add_column :to_dos, :reminder_id, :integer
  end
end
