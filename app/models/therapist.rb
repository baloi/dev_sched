class Therapist < ActiveRecord::Base
  has_many :sessions

  #has_many :therapist_residents
  #has_many :residents, :through => :therapist_residents

  def active_residents
    ar = residents.select{|x| x.active == true}
    ar
  end
end
