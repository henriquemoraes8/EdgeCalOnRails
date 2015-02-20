class AddUserToDo < ActiveRecord::Migration
  def change
    add_column :to_dos, :creator_id, :integer
  end
end
