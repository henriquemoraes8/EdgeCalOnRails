class CreateEvents < ActiveRecord::Migration
  def change

    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.references :creator
      t.references :repetition_scheme
      t.timestamps null: false
    end

  end
end
