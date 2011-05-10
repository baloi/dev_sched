require File.dirname(__FILE__) + '/../test_helper'

class CaseloadTest < Test::Unit::TestCase
  fixtures :sessions
  fixtures :rehab_days
  fixtures :therapists

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_associations
    # each caseload should belong to a rehab day
    # each rehab day should have one to many caseloads

    # each caseload should have one therapist
    # each therapist can have many caseloads but only one for the day

    # each caseload should have sessions
    # each session should belong to only one caseload

    
  end

  def test_group_day

  end

  def test_one_caseload
    
    rehab_day_id = 1
    therapist_id = 1
    caseload = Caseload.new(rehab_day_id, therapist_id)
    
    
    assert_equal 5, caseload.sessions.length
  end

  def test_should_have_time_array
    rehab_day_id = 1
    therapist_id = 1
    caseload = Caseload.new(rehab_day_id, therapist_id)
 
    assert_equal "08:00 AM", caseload.time_array[0] 

    assert_equal "04:00 PM", caseload.time_array.last
    
    #puts ".>>>"
    #caseload.time_array.each do |t|

    #  puts t

    #end 
    #puts "<<<."
    assert_equal 33, caseload.time_array.length
  end

  def test_should_have_time_entries
    rehab_day_id = 1
    therapist_id = 1
    caseload = Caseload.new(rehab_day_id, therapist_id)
 
    assert_equal 0, caseload.time_entries["08:00 AM"].length

    #caseload.sessions.each do |c|
    #  puts ">>> ts =  #{c.time_start_hhmm}<<<"
    #end
    assert_equal 'first session', caseload.time_entries["09:45 AM"][0].description
  end

  def test_to_html
    rehab_day_id = 1
    therapist_id = 1
    caseload = Caseload.new(rehab_day_id, therapist_id)
  
    caseload.to_html
  end
end
