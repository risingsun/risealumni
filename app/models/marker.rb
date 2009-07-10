class Marker < ActiveRecord::Base

  has_one :profile
  has_one :event
  validates_presence_of :lat
  validates_presence_of :lng
  
end
