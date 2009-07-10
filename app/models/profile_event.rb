class ProfileEvent < ActiveRecord::Base
  belongs_to :profile 
  belongs_to :event 
  validates_presence_of :role
  validates_presence_of :profile
  validates_presence_of :event
  validates_uniqueness_of :profile_id, :scope => :event_id, :message => 'has already.'

  def is_organizer?
    self.role =='Organizer'
  end
end
