require File.expand_path(File.dirname(__FILE__)) + '/../scheduler'
require 'rspec'

module WebSpecHelper
 
  def input_initial_day
    visit '/baloi/create_data'

    visit '/day/new'
    fill_in "year", :with => "2010"
    fill_in "month", :with => "10"
    fill_in "day", :with => "10"
    click_button "Submit"

  end

  def input_first_session
    input_initial_day
    visit '/group/new'
    #puts ">>>#{last_response.body}<<<"
    
    select "PT"
    select "Telli"
    fill_in "time_start", :with => "9:30"
    fill_in "time_end", :with => "10:15"
    click_button "Submit"

    follow_redirect!
    #puts ">>>#{last_response.body}<<<"
    
  end

  def create_one_group_with_residents
    create_first_session

    gid = Group.all.first.id

    first_resident = Resident.all.first.id
    add_resident_to_group(gid, first_resident)

    last_resident = Resident.all.last.id
    add_resident_to_group(gid, last_resident)
  end

  def create_first_session
    get '/baloi/create_data'
    post '/day', {:year => 2010, :month => 10, :day => 10}

    follow_redirect!
    
    #add sessions/group to the day
    post '/group', {
            :time_start => "9:10", 
            :time_end => "10:10", 
            :session_type => "PT",
            :therapist => Therapist.all.first.id}
    #puts ">>>#{Therapist.all.first.id}<<<"
    follow_redirect!

  end

  def add_resident_to_group(group, resident)
    # add at least a resident to the group
    post "/group/add_resident/#{group}", {:resident => resident}

    follow_redirect!
  end


end

module MySpecHelper
  def delete_all_data
    Resident.destroy
    Therapist.destroy
    Group.destroy
    Session.destroy
    PTTreatment.destroy
    OTTreatment.destroy
    RehabDay.destroy
    Schedule.destroy
    Conflict.destroy
    ResidentConflict.destroy
    TherapistConflict.destroy
    ResidentSession.destroy
    TherapistResident.destroy
  end
end

module GroupSpecHelper
  def normal_group
    r1 = Resident.new
    r1.name = 'Doberts, Charles'
    r2 = Resident.new
    r2.name = 'Strauss, Levis'
    therapist = PhysicalTherapist.new
    therapist.name = 'baloi'

    #r1.therapist = therapist
    #r2.therapist = therapist
 
    {:residents => [r1, r2], 
              :therapist => therapist,
              :time_start => '9:30',
              :time_end => '10:30'
    }
  end

  def another_group
    r1 = Resident.new
    r1.name = 'Hillie, Billy'
    r2 = Resident.new
    r2.name = 'Lee, Colonel'
    therapist = PhysicalTherapist.new
    therapist.name = 'Deloi'
 
    {:residents => [r1, r2], 
              :therapist => therapist,
              :time_start => '11:00',
              :time_end => '11:45'
    }
  end

  def blank_resident_group

    therapist = PhysicalTherapist.new
    therapist.name = 'baloi'
 
    {:therapist => therapist,
      :time_start => '9:30',
      :time_end => '10:30'
    }
  end


end

module SchedulerSpecHelper 

  def initial_residents
    residents = []
    r1 = Resident.new
    r1.name = 'Cuneta, Sharon'
    r1.pt_minutes_per_day = 60 
    r1.pt_days_per_week = 5 
    r1.ot_minutes_per_day = 60 
    r1.ot_days_per_week = 5 

    residents << r1

    r2 = Resident.new
    r2.name = 'Alonzo, Bea'
    r2.pt_minutes_per_day = 60 
    r2.pt_days_per_week = 5 
    r2.ot_minutes_per_day = 60 
    r2.ot_days_per_week = 5 

    residents << r2

    r3 = Resident.new
    r3.name = 'Hermosa, Christine'
    r3.pt_minutes_per_day = 60 
    r3.pt_days_per_week = 5 
    r3.ot_minutes_per_day = 45 
    r3.ot_days_per_week = 5 

    residents << r3


    r4 = Resident.new
    r4.name = 'Revillame, Willie'
    r4.pt_minutes_per_day = 60 
    r4.pt_days_per_week = 5 
    r4.ot_minutes_per_day = 60 
    r4.ot_days_per_week = 5
    r4.active = false
    residents << r4

    r5 = Resident.new
    r5.name = 'Pascual, Piollo'
    r5.pt_minutes_per_day = 60 
    r5.pt_days_per_week = 5 
    r5.ot_minutes_per_day = 45 
    r5.ot_days_per_week = 5 
    residents << r5

  end  

  def save_model_array(model)
    model.each do |m|
      m.save
    end 
  end

  def create_initial_residents
    save_model_array(initial_residents) 
  end

  def normal_treatment(day, resident)

    treatment = PTTreatment.new
    treatment.time_start = SimpleTime.nine_thirty_am(day) 
    treatment.time_end = SimpleTime.ten_thirty_am(day) 
    treatment.therapist = Therapist.all.first

    resident.sessions << treatment
    resident.save

    treatment
  end

  def conflicting_treatment(day, resident)

    treatment = OTTreatment.new
    treatment.time_start = SimpleTime.ten_o_clock_am(day) 
    treatment.time_end = SimpleTime.eleven_o_clock_am(day) 
    treatment.therapist = Therapist.all.last

    resident.sessions << treatment
    resident.save
 
    treatment
  end

  def late_treatment(day, resident)

    treatment = PTTreatment.new
    treatment.time_start = SimpleTime.ten_thirty_am(day) 
    treatment.time_end = SimpleTime.eleven_fifteen_am(day) 
    treatment.therapist = Therapist.all.first

    resident.sessions << treatment
    resident.save
 
    treatment
  end

  def conflicting_late_treatment(day, resident)
    treatment = PTTreatment.new
    treatment.time_start = SimpleTime.eleven_o_clock_am(day) 
    treatment.time_end = SimpleTime.eleven_thirty_am(day) 
    treatment.therapist = Therapist.all.last

    resident.sessions << treatment
    resident.save
 
    treatment
  end

end
