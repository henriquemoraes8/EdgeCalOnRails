class ToDoOnRepetition < ActiveRecord::Migration
  def change
    add_column :to_dos, :repetition_scheme_id, :integer
    add_column :repetition_schemes, :preference_based, :boolean, :default => false
    add_column :repetition_schemes, :creator_id, :integer

    create_table :repetition_schemes_users, id: false do |t|
      t.integer :repetition_scheme_id
      t.integer :user_id
    end
  end
end

