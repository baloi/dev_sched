class ResidentSession < ActiveRecord::Base
  belongs_to :resident
  belongs_to :session
end
