class AddEventParamsToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :title, :string
    add_column :requests, :description, :string
    add_column :requests, :start_time, :datetime
    add_column :requests, :end_time, :datetime
  end
end
