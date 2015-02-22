class AddDescriptionToDo < ActiveRecord::Migration
  def change
    add_column :to_dos, :title, :string, :null => false
    add_column :to_dos, :description, :string
  end
end
