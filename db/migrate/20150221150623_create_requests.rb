class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :request_map_id, null: false
      t.timestamps null: false
    end
  end
end
