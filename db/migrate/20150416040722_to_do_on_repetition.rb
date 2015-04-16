class ToDoOnRepetition < ActiveRecord::Migration
  def change
    add_column :to_dos, :repetition_scheme_id, :integer
    add_column :repetition_schemes, :preference_based, :boolean, :default => false
    add_column :repetition_schemes, :creator_id, :integer
  end
end

