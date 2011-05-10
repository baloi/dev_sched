require File.dirname(__FILE__) + '/../test_helper'

class TherapistTest < Test::Unit::TestCase
  fixtures :therapists

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_should_have_residents
    therapist = PhysicalTherapist.create(:name => "baloi")
    r1 = Resident.create(:name => "Barka, Tanya")
    r2 = Resident.create(:name => "Puwa, Lega") 

    therapist.residents << r1
    therapist.residents << r2
    assert_equal true, therapist.save
  end
end
