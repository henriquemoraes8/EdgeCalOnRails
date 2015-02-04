class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.integer :member_id
      t.integer :member_of_group_id
      t.timestamps null: false
    end
  end
end
