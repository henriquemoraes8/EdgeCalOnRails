class FieldsToDo < ActiveRecord::Migration
  def change
    add_column :to_dos, :expiration, :datetime
    add_column :to_dos, :job_id, :integer
    add_column :to_dos, :escalation_prior, :integer, :default => 0
    add_column :to_dos, :escalation_recurrence, :integer, :default => 0
    add_column :to_dos, :escalation_step, :integer
  end
end
