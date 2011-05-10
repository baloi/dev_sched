require File.expand_path(File.dirname(__FILE__)) + '/spec_helpers'
require File.expand_path(File.dirname(__FILE__)) + '/../app_helpers'

include MySpecHelper
include GroupSpecHelper
include SchedulerSpecHelper

describe Resident do
  before(:each) do
    delete_all_data
  end

  it "should have both a last name and a first name" do

    res = Resident.new
    res.should_not be_valid

    res.name = "Lopey, Fopey"
    res.should be_valid

    res.last_name.should == 'Lopey'
    res.first_name.should == 'Fopey'
  end

  it "should have treatment time per day" do
    r1 = Resident.new
    r1.name = "Barete, Grace"
    r1.pt_minutes_per_day = 60
    r1.ot_minutes_per_day = 60
    r1.save.should == true
    r1.saved?.should == true
  end

  it "should have number of treatments per week" do
    r1 = Resident.new
    r1.name = "Barete, Grace"
    r1.pt_days_per_week = 5 
    r1.ot_days_per_week = 5 

    r1.save.should == true
    r1.saved?.should == true
  end

  it "should have a room" do
    r1 = Resident.new
    r1.name = "Barete, Grace"
    r1.room = "501B" 
    r1.save.should == true
    r1.saved?.should == true

  end

  it "should have a unique name" do

    res = Resident.new
    res.should_not be_valid

    res.name = "Lopey, Fopey"
    res.save.should == true
    res.should be_valid

    res2 = Resident.new

    res2.name = "Lopey, Fopey"
    res2.should_not be_valid
    res2.save.should == false

    res3 = Resident.new

    res3.name = "Gali, Cani"
    res3.should be_valid
    res3.save.should == true

  end

  it "should be saveable" do 
    res = Resident.new
    res.name = "Lopey, Fopey"
    res.should be_valid

    if res.save
      res.saved?.should == true
    else
      # test failed
      res.errors.each do |e|
        puts ">>>#{e}<<<"
      end
    end
  end
  
  it "should have one ore more therapists" do
    
    resident = Resident.new
    resident.name = "Tino, Tere"


    t1 = PhysicalTherapist.new
    t1.name = "Loi"

    t2 = PhysicalTherapist.new
    t2.name = "Balo"

    resident.therapists << t1
    resident.therapists << t2

    resident.should be_valid
    resident.save.should == true
    resident.saved?.should == true
    t1.saved?.should == true
    t2.saved?.should == true

    resident.therapists.first.name.should == "Loi"
    resident.therapists.last.name.should == "Balo"
  end

  it "should be able to participate in one or more groups" do
    group1 = PTGroup.new
    group1.attributes = normal_group

    group2 = PTGroup.new
    group2.attributes = another_group

    resident = Resident.new
    resident.name = "Aquini, Alberti"

    group1.residents << resident
    group2.residents << resident

    group1.residents.first.name.should == "Doberts, Charles" 
    group1.residents.last.name.should == "Aquini, Alberti" 
    group1.residents.length.should == 3
 
    group1.save.should == true
    group1.saved?.should == true

    group2.save.should == true
    group2.saved?.should == true

  end

  it "should be able to participate in an OTGroup or a PT Group" do
    pt_group = PTGroup.new
    pt_group.attributes = normal_group

    ot_group = OTGroup.new
    ot_group.attributes = another_group

    resident = Resident.new
    resident.name = "Aquini, Alberti"

    pt_group.residents << resident
    ot_group.residents << resident

    pt_group.residents.first.name.should == "Doberts, Charles" 

    pt_group.residents.last.name.should == "Aquini, Alberti" 
    pt_group.residents.length.should == 3
 
    pt_group.save.should == true
    pt_group.saved?.should == true
  end
end

describe Therapist do
  before(:each) do
    delete_all_data
  end

  it "should have one or more residents" do 

    therapist = PhysicalTherapist.new

    r1 = Resident.new
    r1.name = "Tana, Ta"

    r2 = Resident.new
    r2.name = "Tita, Te"

    therapist.name = "Loi"
    therapist.residents << r1
    therapist.residents << r2

    therapist.should be_valid
  end


  it "should be able to save a Group(s) as its one or more sessions" do
    therapist = PhysicalTherapist.new
    therapist.name = "Janan"

    g1 = PTGroup.new
    g2 = PTGroup.new 

    g1.attributes = normal_group
    g2.attributes = another_group

    therapist.should be_valid
    therapist.sessions << g1
    therapist.sessions << g2


    therapist.save.should == true
    therapist.saved?.should == true
    g1.saved?.should == true
    g2.saved?.should == true
  end

  it "should have a name" do
    therapist = PhysicalTherapist.new
    therapist.should_not be_valid
    therapist.name = "Janan"
    therapist.should be_valid
  end

  it "should be an OT or a PT" do
    t = PhysicalTherapist.new 
    t.type.should == PhysicalTherapist
  end
end

describe Group do
  before(:each) do
    delete_all_data
  end

  it "should be able to add residents to a group" do
    group = PTGroup.new

    group.attributes = blank_resident_group
    r1 = Resident.create(:name => "Doney, Tony")
    r2 = Resident.create(:name => "Check, Budget")

    group.residents << r1
    group.residents << r2

    group.save.should == true
    group.saved?.should == true


    r1.saved?.should == true
    r2.saved?.should == true

  end

  it "should be able to delete a resident from a group" do
    group = PTGroup.new
    group.attributes = normal_group 
    group.save.should == true
    group.saved?.should == true

    resident = "Strauss, Levis"
    group.has_resident?(resident).should  == true
    group.residents.length.should == 2
    
    group.delete_resident(resident) 

    group.save.should == true

    group.has_resident?(resident).should ==  false
    group.has_resident?("Doberts, Charles").should ==  true
    group.residents.length.should == 1

    #residents = group.residents
    #puts ">>>residents #{resident}<<<"
  end

  it "should be able to check if resident is in the group" do
    group = PTGroup.new

    group.attributes = normal_group 
    # Test if creating another group will affect "group" object attributes
    another = PTGroup.new
    another.attributes = another_group
    another.save.should == true

    group.save.should == true
    group.saved?.should == true

    group.residents.create(:name => "Doney, Tony")
    group.residents.create(:name => "Check, Budget")


    g2 = PTGroup.get(group.id)
    #g2 = Group.first(:time_start => '11:00')


    g2.has_resident?('Doberts, Charles').should == true
    g2.has_resident?('Doney, Tony').should == true
    g2.has_resident?('Check, Budget').should == true
    g2.has_resident?('rr').should == false
  end

  it "should belong to a RehabDay" do
    group = PTGroup.new
    group.attributes = normal_group

    rehab_day = RehabDay.new
    day = Day.new(2010, 7, 21)
    rehab_day.set_day(day)
    rehab_day.sessions << group

    rehab_day.save.should == true
    rehab_day.saved?.should == true
 end

  it "should have a therapist" do
    group = PTGroup.new

    group.attributes = normal_group 
    group.therapist.name.should == 'baloi'
  end
end

describe Session do

  before(:each) do
    delete_all_data
  end

  it "should have residents" do
    session = PTGroup.new
    session.attributes = normal_group
    session.save.should == true

    residents = session.residents

    #all_res = residents.all
    #all_res.each do |res|
    #puts ">>>levis #{res}<<<"
    #end

    name = 'Strauss, Levis'
    r = residents.all.find {|res| res.name == name}
    r.name.should == name 

    session.residents.length.should == 2
  end

  it "should have one therapist" do

    therapist = PhysicalTherapist.new
    therapist.name = "jana"
    therapist.should be_valid

    session = PTGroup.new
    session.attributes = normal_group

    session.therapist = therapist
    session.should be_valid

    session.save.should == true
    session.saved?.should == true
    therapist.saved?.should == true
  end

  it "should have a start and end time" do
    session = Session.new
    # start time 9:30 am Oct 13, 2010
    time_start = Time.mktime(2010, 10, 13, 9, 30)
    session.time_start = time_start
    # end time 10:15 am Oct 13, 2010
    time_end = Time.mktime(2010, 10, 13, 10, 15)
    session.time_end = time_end
    #puts ">>> session.time_start = #{session.time_start}<<<"
    #puts ">>> time_start = #{time_start}<<<"

    session.time_start.should == time_start
    session.time_end.should == time_end
  end

  it "should check if it encompasses another session" do

    s1 = Session.new
    day = Day.new(2010, 11, 14)
    s1.time_start = SimpleTime.nine_thirty_am(day)
    s1.time_end = SimpleTime.ten_thirty_am(day)

    s2 = Session.new
    s2.time_start = SimpleTime.nine_o_clock_am(day)
    s2.time_end = SimpleTime.eleven_o_clock_am(day)

    # s1 within s2 
    s2.encompasses?(s1).should == true
    #puts "enc 1"
    s1.encompasses?(s2).should == false
    #puts "enc 2"
  
  end

  it "should check if it is within another session" do

    s1 = Session.new
    day = Day.new(2010, 11, 14)
    s1.time_start = SimpleTime.nine_thirty_am(day)
    s1.time_end = SimpleTime.ten_thirty_am(day)

    s2 = Session.new
    s2.time_start = SimpleTime.nine_o_clock_am(day)
    s2.time_end = SimpleTime.eleven_o_clock_am(day)

    # s1 within s2 
    s1.within?(s2).should == true
    #puts "within 1"
    s2.within?(s1).should == false
    #puts "within 2"
  
  end

  it "should check for overlaps in times" do

    s1 = Session.new
    day = Day.new(2010, 11, 14)
    s1.time_start = SimpleTime.nine_thirty_am(day)
    s1.time_end = SimpleTime.ten_thirty_am(day)

    s2 = Session.new
    s2.time_start = SimpleTime.ten_o_clock_am(day)
    s2.time_end = SimpleTime.eleven_o_clock_am(day)

    s3 = Session.new
    s3.time_start = SimpleTime.eight_thirty_am(day)
    s3.time_end = SimpleTime.nine_thirty_am(day)

    s4 = Session.new
    s4.time_start = SimpleTime.ten_thirty_am(day)
    s4.time_end = SimpleTime.eleven_o_clock_am(day)

    s5 = Session.new
    s5.time_start = SimpleTime.eight_thirty_am(day)
    s5.time_end = SimpleTime.eleven_o_clock_am(day)

    s6 = Session.new
    s6.time_start = SimpleTime.eight_thirty_am(day)
    s6.time_end = SimpleTime.nine_o_clock_am(day)

    # time start overlaps 
    s1.overlaps?(s2).should == true
    #puts "1 done"
    s2.overlaps?(s1).should == true
    #puts "2 done"
    # time end overlaps

    # s1 time start should not overlap s3 time end
    s1.overlaps?(s3).should == false
    #puts "3 done"
    s3.overlaps?(s1).should == false
    #puts "4 done"
  
    # s4 time start should not overlap s1 time end
    s1.overlaps?(s4).should == false
    #puts "5 done"
    s4.overlaps?(s1).should == false
    #puts "6 done"
    
    s1.overlaps?(s5).should == true
    #puts "7 done"
    s5.overlaps?(s1).should == true
    #puts "8 done"

    s1.overlaps?(s6).should == false
    #puts "9 done"
    s6.overlaps?(s1).should == false
    #puts "10 done"

  
  end

  it "should not overlap itself" do
    s1 = Session.new
    day = Day.new(2010, 11, 14)
    s1.time_start = SimpleTime.nine_thirty_am(day)
    s1.time_end = SimpleTime.ten_thirty_am(day)

    s1.save
    s1.overlaps?(s1).should == false

    s1a = Session.new
    day = Day.new(2010, 11, 14)
    s1a.time_start = SimpleTime.nine_thirty_am(day)
    s1a.time_end = SimpleTime.ten_thirty_am(day)

    s1a.overlaps?(s1).should == true
 
  end
end

describe Treatment do
  before(:each) do
    delete_all_data
  end

#  it "should belong to a rehab day"

  it "should have a resident and a therapist" do
    r = Resident.new
    r.name = "Lopez, Artemio"

    t = PhysicalTherapist.new
    t.name = "baloi"

    tx = Treatment.new
    tx.time_start = Time.mktime(2010, 10, 13, 9, 30)
    tx.time_end = Time.mktime(2010, 10, 13, 10, 15)
    tx.therapist = t
    tx.residents << r

    tx.save.should == true
    tx.saved?.should == true

    tx.residents.first.name.should == "Lopez, Artemio"
    tx.therapist.name.should == "baloi"
    tx.residents.length.should == 1

    tx.has_resident?("bala bala").should_not == true
    rd = RehabDay.new
    day = Day.new(2010, 10, 21)
    rd.set_day(day)
    rd.sessions << tx
    rd.save.should == true
    rd.saved?.should == true
  end
end

describe Schedule do
  before(:each) do
    delete_all_data
  end

  it "should have minutes" do
    s = PTSchedule.new
    s.minutes = 60
    s.save.should == true
    s.saved?.should == true
  end

  it "should have minutes done" do
    s = PTSchedule.new
    s.minutes = 60
    s.minutes_done = 60
    s.save.should == true
    s.saved?.should == true
  end

  it "should belong to a resident" do
    s = PTSchedule.new
    s.minutes = 60
  
    r = Resident.new
    r.name = "Family, First"
    r.schedules << s

    r.save.should == true
    r.saved?.should == true
    s.saved?.should == true
  end

  it "should can be linked to a resident" do
    s = PTSchedule.new
    s.minutes = 60
    s.save.should == true

    r = Resident.new
    r.name = "Family, First"

    s.resident = r

    if s.save
      #puts ">>> schedule saved<<<"
      s.saved?.should == true
    else
      #puts ">>> schedule NOT saved<<<"
      # test failed
      s.errors.each do |e|
        puts ">>>#{e}<<<"
      end
    end

    r2 = Resident.get(r.id)
    r2.name.should == "Family, First"
    r2.schedules.first.minutes.should == 60
    s.saved?.should == true

  end

  it "should be either an OT or a PT schedule" do
    pts = PTSchedule.new
    pts.minutes = 60
    ots = OTSchedule.new
    ots.minutes = 60

    r = Resident.new
    r.name = "Family, First"

    pts.resident = r
    ots.resident = r
    if pts.save
      #puts ">>> schedule saved<<<"
      #puts ">>> sched methods = #{pts.methods - Object.methods}<<<"
      #puts ">>> sched type = #{pts.attributes}<<<"
      pts.saved?.should == true
    else
      puts ">>> schedule NOT saved<<<"
      # test failed
      pts.errors.each do |e|
        puts ">>>#{e}<<<"
      end
    end

    ots.save.should == true
    ots.saved?.should == true
  end

  it "should belong to a rehab day" do
    rd = RehabDay.new
    day = Day.new(2010, 10, 18)
    rd.set_day(day)

    rd.save.should == true
    rd.saved?.should == true
    
    resident = Resident.new
    resident.name = 'Doberts, Charles'
    
    schedule = PTSchedule.new
    schedule.minutes = 60
    schedule.resident = resident

    rd.schedules << schedule
    rd.save.should == true
    rd.saved?.should == true
    #rd.schedules << 
  end

  it "should be able to get sessions for a resident from a rehab day" do
    rd = RehabDay.new
    day = Day.new(2010, 10, 18)
    rd.set_day(day)
          
    otg = OTGroup.new
    otg.attributes = normal_group

    g2 = Group.new
    g2.attributes = another_group

    rd.sessions << otg
    rd.sessions << g2

    rd.save.should == true
    rd.saved?.should == true

    rd_id = rd.id
    rd_test = RehabDay.get!(rd_id)


  end
end

describe Conflict do
  before(:each) do
    delete_all_data
  end

  it "should be either a Therapist or Resident conflict" do
    rc = ResidentConflict.new
    tc = TherapistConflict.new

    rc.kind_of?(Conflict).should == true
    tc.kind_of?(Conflict).should == true
  end

  it "should be either resolved or not" do
    rc = ResidentConflict.new
    rc.resolved?.should == false
    rc.resolve
    #rc.resolved?.should == true

    rc.saved?.should == true
    id = rc.id

    rc2 = Conflict.get!(id)
    rc2.resolved?.should == true
  end
end

describe ResidentConflict do
  it "should have resident sessions" do
    rd = RehabDay.new
    day = Day.new(2010, 10, 10)
    rd.set_day day
    rc = ResidentConflict.new

    treatment = PTTreatment.new

    treatment.time_start = SimpleTime.nine_thirty_am(day)
    treatment.time_end = SimpleTime.ten_thirty_am(day)

    resident = Resident.new
    resident.name = "Frugal, John"

    resident.sessions << treatment

    resident.save.should == true
    resident.saved?.should == true
  
    resident_session = ResidentSession.first(:session => treatment, :resident => resident)
    
    #puts ">>>resident_session.session = #{resident_session.session.short_description}<<<"
    #puts ">>>resident_session.resident = #{resident_session.resident.name}<<<"
    rc.resident_sessions << resident_session 

    rc.save
    rc.saved?.should == true

    ################3
    treatment = PTTreatment.new
    treatment.time_start = SimpleTime.ten_o_clock_am(day)
    treatment.time_end = SimpleTime.eleven_o_clock_am(day)

    resident.sessions << treatment

    resident.save.should == true
    resident.saved?.should == true
  
    resident_session = ResidentSession.first(:session => treatment, :resident => resident)
    
    #puts ">>>resident_session.session = #{resident_session.session.short_description}<<<"
    #puts ">>>resident_session.resident = #{resident_session.resident.name}<<<"
    rc.resident_sessions << resident_session 

    rc.save
    rc.saved?.should == true

    rc.resident_sessions.length.should == 2

    rc.resident_sessions.first.session.time_end.should ==
        SimpleTime.ten_thirty_am(day)
    rc.resident_sessions.last.session.time_start.should ==
        SimpleTime.ten_o_clock_am(day)

  end
end
