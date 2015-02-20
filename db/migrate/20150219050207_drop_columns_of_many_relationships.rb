class DropColumnsOfManyRelationships < ActiveRecord::Migration
  def change
    remove_column :users, :created_events_id
    remove_column :users, :subscriptions_id
    remove_column :users, :subscribed_events_id
    remove_column :users, :memeberships_id
    remove_column :users, :member_of_group_id
    remove_column :memberships, :member_of_group_id
    add_column :memberships, :group_id, :integer
    remove_column :events, :subscribers_id
    remove_column :events, :subscriptions_id
  end
end
