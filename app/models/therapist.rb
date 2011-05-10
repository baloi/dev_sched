class Therapist < ActiveRecord::Base
  has_many :sessions

  #has_many :therapist_residents
  #has_many :residents, :through => :therapist_residents

end
