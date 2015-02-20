class AddRecurrencesToToDo < ActiveRecord::Migration
  def change
    add_column :to_dos, :recurrence, :integer, :default => 0

  end
end
