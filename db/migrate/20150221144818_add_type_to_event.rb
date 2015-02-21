class AddTypeToEvent < ActiveRecord::Migration
  def change
    add_column :events, :type, :integer, :default => 0
    add_column :events, :to_do_id, :integer
    add_column :events, :request_map_id, :integer
  end
end
