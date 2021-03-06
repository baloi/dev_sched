# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 14) do

  create_table "conflicts", :force => true do |t|
    t.column "type",         :string,  :limit => nil,                    :null => false
    t.column "resolved",     :boolean,                :default => false
    t.column "rehab_day_id", :integer
  end

  add_index "conflicts", ["rehab_day_id"], :name => "index_conflicts_rehab_day"

  create_table "rehab_days", :force => true do |t|
    t.column "year",         :integer, :null => false
    t.column "month",        :integer, :null => false
    t.column "day_of_month", :integer, :null => false
  end

  create_table "resident_sessions", :force => true do |t|
    t.column "session_id",           :integer, :null => false
    t.column "resident_id",          :integer, :null => false
    t.column "resident_conflict_id", :integer
  end

  add_index "resident_sessions", ["session_id"], :name => "index_resident_sessions_session"
  add_index "resident_sessions", ["resident_id"], :name => "index_resident_sessions_resident"
  add_index "resident_sessions", ["resident_conflict_id"], :name => "index_resident_sessions_resident_conflict"

  create_table "residents", :force => true do |t|
    t.column "name",                      :string,   :limit => 50,                   :null => false
    t.column "pt_minutes_per_day",        :integer
    t.column "ot_minutes_per_day",        :integer
    t.column "pt_days_per_week",          :integer
    t.column "ot_days_per_week",          :integer
    t.column "active",                    :boolean,                :default => true
    t.column "room",                      :string,   :limit => 50
    t.column "insurance",                 :string,   :limit => 50
    t.column "eval_date",                 :datetime
    t.column "physical_therapist_id",     :integer
    t.column "occupational_therapist_id", :integer
  end

  add_index "residents", ["name"], :name => "unique_residents_name", :unique => true

  create_table "schedules", :force => true do |t|
    t.column "minutes",      :integer,                :default => 0, :null => false
    t.column "minutes_done", :integer,                :default => 0
    t.column "type",         :string,  :limit => nil,                :null => false
    t.column "rehab_day_id", :integer
    t.column "resident_id",  :integer
  end

  add_index "schedules", ["rehab_day_id"], :name => "index_schedules_rehab_day"
  add_index "schedules", ["resident_id"], :name => "index_schedules_resident"

  create_table "sessions", :force => true do |t|
    t.column "time_start",   :timestamp,                :null => false
    t.column "time_end",     :timestamp,                :null => false
    t.column "description",  :string,    :limit => 50
    t.column "type",         :string,    :limit => nil, :null => false
    t.column "rehab_day_id", :integer
    t.column "therapist_id", :integer
  end

  add_index "sessions", ["rehab_day_id"], :name => "index_sessions_rehab_day"
  add_index "sessions", ["therapist_id"], :name => "index_sessions_therapist"

# Could not dump table "sqlite_sequence" because of following StandardError
#   Unknown type '' for column 'name'

  create_table "therapists", :force => true do |t|
    t.column "name", :string, :limit => 50,  :null => false
    t.column "type", :string, :limit => nil, :null => false
  end

end
