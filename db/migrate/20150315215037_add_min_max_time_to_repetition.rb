class AddMinMaxTimeToRepetition < ActiveRecord::Migration
  def change
    add_column :repetition_schemes, :min_time_slot_duration, :integer
    add_column :repetition_schemes, :max_time_slot_duration, :integer
  end
end
