class AddTypeToEvent < ActiveRecord::Migration
  def change
    add_column :events, :type, :integer
    add_column :events, :to_do_id, :integer
    add_column :events, :request_id, :integer
  end
end
