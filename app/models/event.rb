# == Schema Information
# Schema version: 2
#
# Table name: events
#
#  id                    :integer(11)   not null, primary key
#  start_date            :datetime      
#  end_date              :datetime      
#  title                 :string(255)   
#  place                 :string(255)   
#  type                  :string(255)   
#  description           :text          
#  first_contact_person  :string(255)   
#  created_by            :integer(11)   
#  created_at            :datetime      
#  updated_at            :datetime      
#  second_contact_person :string(255)   
#  third_contact_person  :string(255)   
#  fourth_contact_person :string(255)   
#  fifth_contact_person  :string(255)   
#

class Event < ActiveRecord::Base
  validates_presence_of :title

  has_many :profile_events,:dependent => :destroy
  has_many:profiles,:through => :profile_events
  has_many :organizers,:through => :profile_events,:source => :profile,:conditions => "profile_events.role = 'Organizer'"
  has_many :attending,:through => :profile_events,:source => :profile,:conditions => "profile_events.role = 'Attending'"
  has_many :not_attending,:through => :profile_events,:source => :profile, :conditions => "profile_events.role = 'Not Attending'"
  has_many :may_be_attending,:through => :profile_events,:source => :profile,:conditions => "profile_events.role = 'May Be Attending'"
  belongs_to :marker, :dependent => :destroy
  has_many :comments, :as => :commentable, :order => "created_at DESC"
 
  def marker=(marker_hash)
    if (marker_hash[:lat].blank? or marker_hash[:lng].blank? or (marker_hash[:lat] == '0' and marker_hash[:lng] == '0'))
      marker.destroy if marker
      return
    elsif marker
      marker.update_attributes(marker_hash)
    else
      build_marker(marker_hash)
    end
  end
  
  def set_organizer(profile)
    ProfileEvent.create(:event_id => self.id,:profile_id => profile.id,:role =>"Organizer")
  end
  def responded?(profile)
    profile.events.find(:first,:conditions =>{:id => self.id})
  end
  def list(type,size=6)
     self.send(type).find(:all, :limit => size, :order => 'RAND()') rescue []
  end
    
end
