# == Schema Information
# Schema version: 2
#
# Table name: educations
#
#  id                  :integer(11)   not null, primary key
#  profile_id          :integer(11)   
#  highschool_name     :string(255)   
#  education_from_year :string(255)   
#  education_to_year   :string(255)   
#  university          :string(255)   
#  created_at          :datetime      
#  updated_at          :datetime      
#

class Education < ActiveRecord::Base
  
  
  belongs_to :profile
  
  validates_format_of :education_from_year, :education_to_year, :with => /^\d\d\d\d$/, 
                      :message => 'Invalid Year', :allow_blank => :true
  
end
