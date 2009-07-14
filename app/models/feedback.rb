# == Schema Information
# Schema version: 2
#
# Table name: feedbacks
#
#  id         :integer(11)   not null, primary key
#  name       :string(255)   
#  email      :string(255)   
#  subject    :string(255)   
#  message    :text          
#  profile_id :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Feedback < ActiveRecord::Base

  belongs_to :profile
  
  validates_presence_of :subject, :message
  validates_presence_of :name, :email, :if => Proc.new { |obj| obj.profile_id.blank? }
  
  validates_captcha :if => Proc.new { |obj| obj.profile_id.blank? }
  

  after_save :send_feedback_to_admin
  
  
  private
  
  def send_feedback_to_admin
    rec_profile = Profile.admin_emails
    ArNotifier.deliver_feedback_mail(self.reload, rec_profile)
  end
end
