class AddToRepetition < ActiveRecord::Migration
  def change
    remove_column :repetition_schemes, :weekdays
    remove_column :repetition_schemes, :year_day
    remove_column :repetition_schemes, :month_day
  end
end
