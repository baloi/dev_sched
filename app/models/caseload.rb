# Objects created will contain caseloads for a therapist by day
class Caseload

  def initialize(rehab_day_id, therapist_id)
    # create the @sessions array
    find_sessions_by_day_and_therapist(rehab_day_id, therapist_id) 

    # create @time_array for times (8:00AM, 8:15AM, ...)
    create_time_array 

    # insert @sessions elements into @time_entries
    create_time_entries
 
  end

  def to_html
    # iterate through @time array and display 
    @time_array.each do |t|
      entries = @time_entries[t]
      if entries.size != 0
        #puts "#{t} entries... "
        entries.each do |entry|
          #puts "    #{entry.description}"
          ""
        end
      else
        #puts t
        ""
      end
    end

  end

  def find_sessions_by_day_and_therapist(rehab_day_id, therapist_id)
      @sessions = Session.find(:all, :conditions => 
          ["therapist_id = #{therapist_id} AND rehab_day_id = #{rehab_day_id}"])
  end

  def create_time_array
    @time_array = Array.new((8.hours + 15.minutes) / 15.minutes) do |i|
      ((Time.now.midnight + 8.hours) + (i * 15.minutes)).strftime("%I:%M %p")
    end
  end

  def time_array
    @time_array
  end

  # insert appropriate session from @sessions into @time_entries 
  # (time array elements will be keys to hash)
  def create_time_entries
    @time_entries = Hash.new
    
    @time_array.each do |t|
      #puts "tyring #{t}" 
      # find a session in @sessions that starts_at t 
      sessions_found = @sessions.select{|x| x.starts_at(t)}

      #if sessions_found.length == 0
      #  puts ">> sessions found is NIL and type is #{sessions_found.class} <<<"
      #else
      #  puts ">>> sessions_found = #{sessions_found}<<<"
      #end

      #if sessions_found.length != 0
      #  puts ">>> adding sessions_found to #{t}<<<"
      #end

      @time_entries[t] = sessions_found
      
    end
  
    #@time_entries["08:00 AM"] = 'hala' 
  end

  #def add_session_to_entries(ses, entries)

  #end

  def sessions
    @sessions
  end

  def time_entries
    @time_entries
  end
end
