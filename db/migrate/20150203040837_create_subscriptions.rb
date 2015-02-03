class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :subscriber_id
      t.integer :subscribed_event_id
      t.boolean :has_email_notification

      t.column :visibility, :integer, default: 0
      t.column :email_notification_time_unit, :integer, default: 0

      t.timestamps null: false
    end
  end
end
