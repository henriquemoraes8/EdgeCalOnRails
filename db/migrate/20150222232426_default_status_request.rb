class DefaultStatusRequest < ActiveRecord::Migration
  def change
    remove_column :requests, :status
    add_column :requests, :status, :integer, default: 0
  end
end
