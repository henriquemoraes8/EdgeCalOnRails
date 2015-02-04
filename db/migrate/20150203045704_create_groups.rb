class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :title
      t.text :description
      t.timestamps null: false

      t.references :memberships
      t.references :members
    end

    add_column :groups, :owner_id, :integer
  end
end
