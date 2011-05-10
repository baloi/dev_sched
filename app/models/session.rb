class Session < ActiveRecord::Base
  has_many :resident_sessions
  has_many :residents, :through => :resident_sessions

  belongs_to :therapist#, :required => false
  belongs_to :rehab_day#, :required => false

  def self.find_all_groups
    session_type = "Group"
    find(:all, :conditions => ["type LIKE ? ", "%#{session_type}%"])
  end

  def time_start_hhmm
    time_start.strftime("%I:%M %p")
  end

  # Returns time_start in 'hh:mm p' format
  # ex. 08:30 AM
  def starts_at(time)
    #puts ">>> time_start_hhmm = #{time_start_hhmm} <<<"
    #puts ">>> time = #{time} <<<"
    if time_start_hhmm == time
      return true
    else
      return false
    end
  end
end
