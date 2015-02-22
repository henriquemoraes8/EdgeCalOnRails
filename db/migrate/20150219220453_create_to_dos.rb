class CreateToDos < ActiveRecord::Migration
  def change
    create_table :to_dos do |t|
      t.boolean :done, default: false
      t.integer :event_id
      t.integer :position, null: false
      t.datetime :duration
      t.timestamps null: false
    end
  end
end
