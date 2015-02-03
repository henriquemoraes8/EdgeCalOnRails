class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :subscriber_id
      t.integer :subscribed_event_id

      t.column :visibility, :integer, default: 0

      t.timestamps null: false
    end
  end
end
