class Resident < ActiveRecord::Base
  has_many :resident_sessions
  has_many :sessions, :through => :resident_sessions

  belongs_to :physical_therapist
  belongs_to :occupational_therapist

  validates_presence_of :name
  validates_uniqueness_of :name

  def last_name
    n = self[:name].split(',')
    n[0].strip
  end

  def first_name
    n = self[:name].split(',')
    n[1].strip
  end

  def self.sort_by_insurance
    find(:all, :order => 'pt_minutes_per_day DESC, pt_days_per_week DESC, insurance')
  end

  def self.for_saturday
    find(:all, :conditions => "pt_days_per_week = 6")
  end

  def self.insurance_types
    ["Med A", "Med B", "Medicaid", "HMO", "RHMO", "VA"]
  end

end
