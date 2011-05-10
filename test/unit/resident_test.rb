require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

class ResidentTest < Test::Unit::TestCase
  fixtures :residents
  fixtures :therapists
  #fixtures :therapist_residents

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_should_have_a_pt
    resident = Resident.create(:name => "Eastwoo, Cli")    
    pt = PhysicalTherapist.create(:name => "Baloi")
    resident.physical_therapist = pt
    
    assert_equal true, resident.save

  end

  def test_physical_therapist_should_be_a_type_of_physical_therapist
    resident = Resident.create(:name => "Eastwoo, Cli")    
    ot = OccupationalTherapist.create(:name => "Jo")
    
    #assert_raise (ArgumentError) { resident.physical_therapist = ot }
    #assert_equal  ActiveRecord::AssociationTypeMismatch, resident.physical_therapist = ot

  end

  ############################
  def test_mocking_a_class_method
    resident = Resident.new
    Resident.expects(:find).with(1).returns(resident)
    assert_equal resident, Resident.find(1)
  end

  def test_mocking_an_instance_method_on_a_real_object
    resident = Resident.new
    resident.expects(:save).returns(true)
    assert resident.save
  end

  ############################

  def test_should_have_both_last_and_fist_names
    res = Resident.new
    assert_equal false, res.valid?

    res.name = "Lopey, Fopey"
    assert_equal true, res.valid?

    assert_equal res.last_name, "Lopey"
    assert_equal res.first_name, "Fopey"
  
    assert_equal res.save, true
  end

  def test_should_have_treatment_time_per_day
    residents = Resident.find(:all)
    assert_equal 3,  residents.length

    first_res = residents(:first)
    assert_equal 60,first_res.pt_minutes_per_day
    assert_equal 70,first_res.ot_minutes_per_day

  end

  def test_should_have_a_unique_name
    r1 = Resident.new
    assert_equal false, r1.valid?

    r1.name = "Lopey, Fopey"
    assert_equal true, r1.valid?
    assert_equal true, r1.save

    r2 = Resident.new
    assert_equal false, r2.valid?

    r2.name = "Lopey, Fopey"
    assert_equal false, r2.valid?

    assert_equal false, r2.save 
  end

  def test_should_have_number_of_treatments_per_week
    residents = Resident.find(:all)
    assert_equal 3,  residents.length

    first_res = residents(:first)
    assert_equal 5,first_res.pt_days_per_week
    assert_equal 5,first_res.ot_days_per_week
  end

  def test_should_have_a_physical_therapist
    pt = PhysicalTherapist.create(:name => "Bal")
    ot = OccupationalTherapist.create(:name => "Atkin")

    #resident = Resident.find(1)
    resident = Resident.create(:name => "Cruz, Juan")

    # !! Why should save() be called first???
    assert_equal true, resident.save
    resident.physical_therapist = pt
    resident.save

    assert_equal pt.name, resident.physical_therapist.name

    # check the other side
    assert_equal 1, pt.residents.length
    assert_equal resident.name, pt.residents.first.name
  end
end
