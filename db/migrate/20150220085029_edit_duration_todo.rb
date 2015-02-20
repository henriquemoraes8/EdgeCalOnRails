class EditDurationTodo < ActiveRecord::Migration
  def change
    remove_column :to_dos, :duration
    add_column :to_dos, :duration, :time
  end
end
