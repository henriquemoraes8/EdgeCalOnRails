class AddSchedulingToDo < ActiveRecord::Migration
  def change
    add_column :to_dos, :next_reschedule, :datetime
  end
end
