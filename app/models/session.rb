class Session < ActiveRecord::Base
  has_many :resident_sessions
  has_many :residents, :through => :resident_sessions

  belongs_to :therapist#, :required => false
  belongs_to :rehab_day#, :required => false

  def self.find_all_groups
    session_type = "Group"
    find(:all, :conditions => ["type LIKE ? ", "%#{session_type}%"])
  end

  def is_group?
    session_type = self.class.to_s
    # if session type ends in 'Group'
    if session_type =~ /Group$/
      return true
    else
      return false
    end
  end
  def details
    str = "#{self.type} by #{self.therapist.name} starts at #{time_end_hhmm}, ending #{time_end_hhmm}"
  end

  def time_start_hhmm
    time_to_hhmm(time_start)
  end

  def time_end_hhmm
    time_to_hhmm(time_end)
  end

  def time_to_hhmm(time)
    time.strftime("%I:%M %p")
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
