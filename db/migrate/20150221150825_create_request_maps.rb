class CreateRequestMaps < ActiveRecord::Migration
  def change
    create_table :request_maps do |t|
      t.integer :event_id, null: false
      t.timestamps null: false
    end
  end
end
