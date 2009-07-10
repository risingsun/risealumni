# == Schema Information
# Schema version: 2
#
# Table name: messages
#
#  id            :integer(11)   not null, primary key
#  subject       :string(255)   
#  body          :text          
#  created_at    :datetime      
#  updated_at    :datetime      
#  sender_id     :integer(11)   
#  receiver_id   :integer(11)   
#  read          :boolean(1)    not null
#  sender_flag   :boolean(1)    default(TRUE)
#  receiver_flag :boolean(1)    default(TRUE)
#

class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "Profile"
  belongs_to :receiver, :class_name => "Profile"
  validates_presence_of :body, :subject, :sender, :receiver
 
  
  
  def delete_message(profile_id)
    if self.sender_id == self.receiver_id
      self.destroy and return if self.system_message
    end
    if profile_id == self.sender_id
      self.sender_flag = false
      self.save
    elsif profile_id == self.receiver_id
      self.receiver_flag = false
      self.save
      self.destroy and return if self.system_message
    end
    if (self.sender_flag == false) && (self.receiver_flag == false)
      self.destroy
    end
  end
   
  def check_view_permission(profile)
    return true if self.sender == profile || self.receiver == profile
    false
  end
 end
