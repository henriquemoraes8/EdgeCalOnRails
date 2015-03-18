class AddMinMaxTimeToRepetition < ActiveRecord::Migration
  def change
    add_column :repetition_schemes, :min_time_slot_duration, :time
    add_column :repetition_schemes, :max_time_slot_duration, :time
  end
end
