class CreateVisibilities < ActiveRecord::Migration
  def change
    create_table :visibilities do |t|
      t.integer :status, null: false
      t.integer :event_id, null: false
      t.integer :position, null: false
      t.integer :user_id, null: true
      t.integer :group_id, null: true
      t.timestamps null: false
    end
  end
end
