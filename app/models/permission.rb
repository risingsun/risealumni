# == Schema Information
# Schema version: 2
#
# Table name: permissions
#
#  id         :integer(11)   not null, primary key
#  profile_id :integer(11)   
#  field      :string(255)   
#  permission :string(255)   default("Friends")
#  created_at :datetime      
#  updated_at :datetime      
#

class Permission < ActiveRecord::Base

  belongs_to :profile
  
  #validates_presence_of :field, :permission, :profile
end
