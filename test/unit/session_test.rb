require File.dirname(__FILE__) + '/../test_helper'

class SessionTest < Test::Unit::TestCase
  fixtures :sessions
  fixtures :residents
  fixtures :rehab_days
  fixtures :therapists

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_fixtures
    therapist = therapists(:one)
    rehab_day = rehab_days(:one)
    pt_treatment = sessions(:simple_session)
    
    # Test fixtures content
    assert_equal pt_treatment.class, PTTreatment 
    assert_equal therapist.class, PhysicalTherapist
    assert_equal pt_treatment.therapist.id, therapist.id 
    assert_equal pt_treatment.rehab_day.id, rehab_day.id 
    assert_equal pt_treatment.description, "simple session"

    # Now let's fetch from the database and see if the fixtures
    # are in...
    rd = RehabDay.find(rehab_day.id)
    assert_equal rd.year, 2011
    assert_equal rd.month, 3
    assert_equal rd.day_of_month, 14 

    t = Therapist.find(1)
    assert_equal t.name, "baloi"
  end

  def test_should_belong_to_rehab_day
    pt_treatment = PTTreatment.new
    
    day = Day.new(2011, 3, 11)
    rehab_day = RehabDay.new
    rehab_day.set_day day
    
    t1 = SimpleTime.eight_thirty_am(day)
    t2 = SimpleTime.nine_thirty_am(day)
    
    pt_treatment.time_start = t1
    pt_treatment.time_end = t2
    pt_treatment.description = "PT treatment belonging to a rehab day"
    
    rehab_day.sessions << pt_treatment

    pt_treatment.save
    rehab_day.save
    
    rd_id = rehab_day.id

    assert_equal pt_treatment.rehab_day.id, rd_id 

  end

  def test_normal_session
    #puts ">>>#{Time.now}<<<"

    #SQL: insert into sessions("rehab_day_id", "therapist_id", "type",
    #       "description", "time_end", "time_start") values()
    pt_treatment = PTTreatment.new
    
    assert_equal pt_treatment.class, PTTreatment

    day = Day.new(2011, 3, 11)
    rehab_day = RehabDay.new
    rehab_day.set_day day
    
    t1 = SimpleTime.eight_thirty_am(day)
    t2 = SimpleTime.nine_thirty_am(day)
    
    pt_treatment.time_start = t1
    pt_treatment.time_end = t2
    pt_treatment.description = "PT treatment session lang"
    
    rehab_day.sessions << pt_treatment

    pt_treatment.save
    rehab_day.save

    assert_equal rehab_day.sessions.count, 1
    assert_equal rehab_day.sessions[0].description, 'PT treatment session lang'
  end

  def test_starts_at
    s = Session.find(1)

    assert_equal true, s.starts_at("03:45 PM") 
    assert_equal false, s.starts_at("03:41 PM") 
    assert_equal false, s.starts_at("03:40 AM") 
  end

  def test_time_start_hhmm
    s = Session.find(1)
    assert_equal "03:45 PM", s.time_start_hhmm
  end

  def test_duration
    #s = PTTreatment.sample
    s = Session.find(1)
  
    #d = 
  end

  def test_is_group
    pt_tx = PTTreatment.new
    ot_tx = OTTreatment.new
    pt_group = PTGroup.new
    ot_group = OTGroup.new
    assert_equal false, pt_tx.is_group?
    assert_equal false, ot_tx.is_group?
    assert_equal true, pt_group.is_group?
    assert_equal true, ot_group.is_group?
  end
end
