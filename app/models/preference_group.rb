class PreferenceGroup < ActiveRecord::Base
  validates_uniqueness_of :group
  has_many :preferences
end
