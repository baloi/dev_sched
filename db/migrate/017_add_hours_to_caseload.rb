class AddHoursToCaseload < ActiveRecord::Migration
  def self.up
	  add_column :caseloads, :hours, :decimal, :precision => 8, :scale => 2
  end

  def self.down
	  remove_column :caseloads, :hours
  end
end
