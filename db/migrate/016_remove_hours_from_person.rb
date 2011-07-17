class RemoveHoursFromPerson < ActiveRecord::Migration
  def self.up
	  remove_column :caseloads, :hours
  end

  def self.down
	  add_column :caseloads, :hours, :integer
  end
end
