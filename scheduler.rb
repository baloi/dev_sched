require File.expand_path(File.dirname(__FILE__)) + '/./calendar'
require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-sqlite-adapter'
require 'dm-migrations'

#DataMapper.setup :default, 'sqlite3::memory:'
DataMapper.setup :default, "sqlite://#{ENV['HOME']}/projects/scheduler/web.db"

class Scheduler
  def active_residents
    Resident.all(:active => true)
  end

  def create_day_schedules(rd)
    residents = active_residents
    schedules = create_resident_schedules(residents) 

    add_schedules_to_day(schedules, rd)
  end
  
  def create_resident_schedules(residents)
    schedules = []
    #puts ">>>residents = #{residents}<<<"

    residents.each do |resident|

      #puts ">>>resident = #{resident}<<<"
      pt_schedule = PTSchedule.new
      pt_schedule.resident = resident
      pt_min = 0
      #puts "pt_mins_per_day >>>#{resident.pt_minutes_per_day}<<<"
      if resident.pt_minutes_per_day != ''
        pt_min = resident.pt_minutes_per_day
      end
      pt_schedule.minutes = pt_min
      #pt_schedule.type = "PT" 
      pt_schedule.save
      schedules << pt_schedule

      ot_schedule = OTSchedule.new
      ot_schedule.resident = resident
      #puts "ot_mins_per_day >>>#{resident.ot_minutes_per_day}<<<"
      ot_min = 0
      if resident.ot_minutes_per_day != ''
        ot_min = resident.ot_minutes_per_day
      end
      ot_schedule.minutes = ot_min 

      #ot_schedule.type = "OT" 
      ot_schedule.save
      schedules << ot_schedule
    end

    schedules
  end

  def add_schedules_to_day(schedules, rehab_day)
    schedules.each do |schedule|
      rehab_day.schedules << schedule
    end
  end

end


class RehabDay
  include DataMapper::Resource
        
  property :id,  Serial
#  property :description, String 
  property :year, Integer,   :required => true
  property :month, Integer,   :required => true
  property :day_of_month, Integer,   :required => true
  
  has n, :sessions
  has n, :schedules
  has n, :conflicts


  def add_session(session)
    # check each resident_session in session for conflicts
    # try to save the session before doing anything
    session.save if ! session.saved?

    # optional
    if has_conflicting_session_with(session)
      find_and_record_session_conflicts(session)
    end

    #puts "adding session #{session.id}, #{session.residents.all.first.name}<<<"
    self.sessions << session
    #puts "add_session end <<<"
  end

  # should check if sess has any session which conflicts with it
  def has_conflicting_session_with( session )
    has_conflict = false

    session.resident_sessions.all.each do |resident_session|
      #puts ">>> finding conflicts with #{resident_session.resident.name}'s session: #{resident_session.session.id} @ #{resident_session.session.time_hhmm}"
      if has_resident_session_conflict( resident_session )
        has_conflict = true
      end
    end


    has_conflict
  end

  def has_resident_session_conflict( resident_session )
    has_conflict = false
    resident = resident_session.resident
    session = resident_session.session 

    self.sessions.resident_sessions.all.each do |existing_resident_session|

      #puts "      existing_resident_session short_description = #{existing_resident_session.session.short_description}"
      #puts "      new_resident_session short_description = #{session.short_description}"
      if existing_resident_session.resident.name == resident.name  
        #puts ">>> existing_resident_session.session.has_resident ...<<<"
        if existing_resident_session.session.overlaps? session
          #puts "        >>> found overlap...<<<"
          has_conflict = true
        end
           
      end
    end

    has_conflict

  end


  def find_and_record_session_conflicts(session)
    session.resident_sessions.all.each do |resident_session|
      #puts ">>> finding conflicts with #{resident_session.resident.name}'s session: #{resident_session.session.id} @ #{resident_session.session.time_hhmm}"
      conflicting_resident_session = find_resident_session_conflict(resident_session) 
      if conflicting_resident_session != nil
        record_conflicting_resident_sessions(conflicting_resident_session, resident_session)

      end
    end
  end


  def record_conflicting_resident_sessions(c1, c2)

    conflict = ResidentConflict.new 
    # add both sessions to resident conflict
    conflict.resident_sessions << c1
    #puts ">>> resident = #{c1.resident.name}, session #{c1.session.time_start} conflicts with "
    conflict.resident_sessions << c2
    #puts "resident = #{c2.resident.name}, session #{c2.session.time_start}<<<"
    conflict.save
    #puts "          >>> conflict.c2.length = #{conflict.resident_sessions.length}..."
    #puts "          <<<"
    #puts "          >>> conflict contents: #{conflict.contents} "
    #puts "          <<<"
    self.conflicts << conflict

  end

  # Find a conflict for resident's session and save them. 
  def find_resident_session_conflict(resident_session)
    conflicting_resident_session = nil
    resident = resident_session.resident
    session = resident_session.session 

    self.sessions.resident_sessions.all.each do |existing_resident_session|

      if existing_resident_session.resident.name == resident.name  
        if existing_resident_session.session.overlaps? session
          #puts "        >>> found overlap...<<<"
          conflicting_resident_session = existing_resident_session
        end
           
        #puts ">>> printing all conflicts after adding"
        #puts all_conflicts
        #puts "<<<"
      end
    end
  
    conflicting_resident_session
  end

  def all_conflicts
    conflicts_content = ""
    self.conflicts.all.each do |c|
      conflicts_content = conflicts_content + c.contents   
    end
    
    conflicts_content
  end

  def date
    "#{self.year}/#{self.month}/#{self.day_of_month}"
  end

  def get_residents
    residents = []

    self.sessions.each do |session|
      #puts ">>> session = #{session}<<< "
      session.residents.each do |resident|
        #puts ">>> resident = #{resident}<<< "
        residents << resident
      end
    end

    #puts ">>> residents = #{residents}<<< "
    residents
  end

  def set_day(day)
    @day = day
    # Attributes of Day class:
    # :year, :month, :date, :day_of_week, :items

    self.year = day.year
    self.month = day.month
    self.day_of_month = day.date
    #puts "#>>> @year = #{@year}"
  end

  def day
    if @day == nil
      @day = Day.new(@year, @month, @day_of_month)
    end

    @day
  end
end

class Session
  include DataMapper::Resource

  property :id,  Serial
  property :time_start, Time, :required => true 
  property :time_end, Time, :required => true 
  property :description, String
  property :type, Discriminator

  has n, :resident_sessions
  has n, :residents, :through => :resident_sessions

  belongs_to :therapist, :required => false
  belongs_to :rehab_day, :required => false


  def time_hhmm
    ts = self.time_start.strftime("%H:%M")
    te = self.time_end.strftime("%H:%M")
    time_hhmm = "#{ts} - #{te}"
  end

  def overlaps?(other_session)
    overlaps = false
    
    if self.id == nil || other_session.id == nil || (self.id != other_session.id && 
        self.id != nil && other_session.id != nil)
      # check only if the Session is not before or after (meaning it
      # it should already not overlap) this session 
      if ! before?(other_session) && ! after?(other_session) 
        overlaps = true if self.time_end > other_session.time_start 
        overlaps = true if self.time_start < other_session.time_end 
      end

      if within?(other_session)
        overlaps = true
      end

      if encompasses?(other_session)
        overlaps = true
      end
    end

    return overlaps
  end

  def encompasses?(other_session)
    encompasses = false

    if self.time_start <= other_session.time_start && self.time_end >= other_session.time_end 
      encompasses = true 
    end

    encompasses
  end

  def within?(other_session)
    within = false
    if self.time_start >= other_session.time_start && self.time_end <= other_session.time_end
      within = true
    end
    within
  end

  def inside?(other_session)
    within?(other_session)
  end
  def before?(other_session)
    self.time_end <= other_session.time_start 
  end

  def after?(other_session)
    self.time_start >= other_session.time_end
  end

  def short_description
    "id=#{self.id}, #{time_hhmm}"
  end
  def get_residents
    #this method should be implemented by inheriting classes
    raise UnimplementedInterfaceMethodError
  end

  def has_resident?(resident)
    # search resident from residents

    found = false

    if self.residents != nil
    #  self.residents.all.each do |x|
        #puts ">>>x.name = #{x.name}"
    #    found = true if x.name == resident
    #  end
        found_resident = nil
        found_resident = self.residents.find { |res| res.name == resident }
        found = true if found_resident != nil 
    end
    #found = self.residents.all(:name => resident)

    return found
  end

end

class ResidentSession
  include DataMapper::Resource

  property :id, Serial 

  belongs_to :resident
  belongs_to :session

  belongs_to :resident_conflict, :required => false
end

class Resident
  include DataMapper::Resource

  property :id,  Serial
  property :name, String, :required => true, :unique => true
  property :pt_minutes_per_day, Integer
  property :ot_minutes_per_day, Integer
  property :pt_days_per_week, Integer
  property :ot_days_per_week, Integer
  property :active, Boolean, :default => true

  property :room, String
  property :insurance, String

  # many-to-many
  has n, :therapist_residents
  has n, :therapists, :through => :therapist_residents

  has n, :resident_sessions
  has n, :sessions, :through => :resident_sessions
  has n, :schedules
#  belongs_to :treatment, :required => false

  def first_name
    n = @name.split(',')
    n[1].strip
  end

  def last_name
    n = @name.split(',')
    n[0].strip
  end

end

class TherapistResident
  include DataMapper::Resource

  property :id, Serial 

  belongs_to :therapist
  belongs_to :resident
end

class Therapist
  include DataMapper::Resource

  property :id,  Serial
  property :name, String, :required => true
  property :type, Discriminator

  # many-to-many
  has n, :therapist_residents
  has n, :residents, :through => :therapist_residents

  has n, :sessions

  #has n, :groups
end

class PhysicalTherapist < Therapist

end

class Treatment < Session

end

class Group < Session

  def delete_resident(resident)
    updated_residents = self.residents.reject {|res| res.name == resident}
    self.residents = updated_residents
  end
end

class PTTreatment < Treatment

end

class OTTreatment < Treatment

end

class PTGroup < Group

end


class OTGroup < Group

end


class Schedule
  include DataMapper::Resource

  property :id,  Serial
  property :minutes, Integer, :required => true, :default => 0
  property :minutes_done, Integer, :default => 0
  property :type, Discriminator # discriminates from OT and PT schedules


  belongs_to :resident, :required => false
  belongs_to :rehab_day, :required => false

  def description
    "#{self.type.to_s} for #{self.resident.name} x #{self.minutes} mins, #{self.minutes_done} mins done"
  end
end

class PTSchedule < Schedule

end

class OTSchedule < Schedule

end


class Conflict
  include DataMapper::Resource

  property :id,  Serial
  property :type, Discriminator # discriminates from OT and PT schedules
  property :resolved, Boolean, :default => false

  belongs_to :rehab_day, :required => false

  def description
    throw UnimplementedInterfaceMethodError
  end

  def resolved?
    self.resolved
  end
  
  def resolve
    self.resolved = true
    self.save 
  end
end

class ResidentConflict < Conflict
  has n, :resident_sessions

  def description
    description = "There is a conflict "
    if self.resident_sessions.all.first != nil
      session1 = self.resident_sessions.all.first.session
      session2 = self.resident_sessions.all.last.session
      resident1=  self.resident_sessions.all.first.resident
      resident2=  self.resident_sessions.all.last.resident

      description = "#{resident1.name}'s #{session1.time_hhmm} #{session1.type.to_s} conflicts with #{resident2.name}'s #{session2.time_hhmm} #{session2.type.to_s}"
    end
    description
  end

  def contents
    c = ""

    self.resident_sessions.all.each do |rs|
      c = c + "\nrs.id = #{rs.id}, session id = #{rs.session.id}, resident = #{rs.resident.name}"
    end
    
    c
  end
end

class TherapistConflict < Conflict
  def description

  end
end

class MissingPropertyError < StandardError; end
class UnimplementedInterfaceMethodError < StandardError; end

DataMapper.finalize
DataMapper.auto_migrate!
