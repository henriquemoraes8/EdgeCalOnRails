class RemoveGroupsManyColumns < ActiveRecord::Migration
  def change
    remove_column :groups, :members_id
    remove_column :groups, :memberships_id
  end
end
