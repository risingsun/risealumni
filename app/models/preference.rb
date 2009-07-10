
class Preference < ActiveRecord::Base

  belongs_to :preference_group
  validates_uniqueness_of :preference_key, :case_sensitive => false
  validates_format_of  :preference_value, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, 
                       :if => proc {|obj| obj.field_type == 'email'} , :message => "Not in email format"
  
  validates_presence_of :preference_key
  validates_presence_of :preference_group_id
  
  def self.find_all_preferences

    preference ={}
    groups = PreferenceGroup.find(:all)
    groups.each do |g|
      preference[g.group] = self.find_preference(g)
    end
    preference.keys.each do|key|
      preference[key] = self.merge_preference(preference[key])
    end
   
    return preference
    
  end

  def self.merge_preference(preference)
    p1={}
    preference.each do |p|
      p1.merge!({p.preference_key.to_sym, p.preference_value})
    end
    return p1
  end

  def self.find_preference(g)
    Preference.find(:all, :select => 'preference_key,preference_value ', :conditions => ['preference_group_id =?', g]) 
  end  
   
end


