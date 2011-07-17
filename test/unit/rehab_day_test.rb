# BALOI FOR WORK LATER 
require File.dirname(__FILE__) + '/../test_helper'

class RehabDayTest < Test::Unit::TestCase
  fixtures :rehab_days
  fixtures :sessions
  fixtures :residents

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_should_have_a_date
    day = Day.new(2011, 3, 11)
    rehab_day = RehabDay.new
    rehab_day.set_day day
    assert_equal rehab_day.date, '2011/3/11'
  end

  def test_has_caseloads
    # each rehab day should have one to many caseloads
    day = Day.new(2011, 3, 11)
    rehab_day = RehabDay.new
    rehab_day.set_day day

    caseload = Caseload.new
    hours = 8.50
    caseload.hours = hours 
    
    rehab_day.caseloads << caseload
    assert_equal rehab_day.caseloads.first.hours, hours
  end

  def test_should_have_many_sessions
    rehab_day = rehab_days(:one)
    pt_treatment = sessions(:simple_session)
 
  end

  def test_should_have_schedules
  end

end
