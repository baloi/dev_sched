class CreateCaseloads < ActiveRecord::Migration
  def self.up
    create_table :caseloads do |t|
      t.column :rehab_day_id, :integer
      t.column :therapist_id, :integer
      t.column :hours, :integer
    end
  end

  def self.down
    drop_table :caseloads
  end
end
