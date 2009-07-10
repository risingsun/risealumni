# == Schema Information
# Schema version: 2
#
# Table name: emails
#
#  id                :integer(11)   not null, primary key
#  from              :string(255)   
#  to                :string(255)   
#  last_send_attempt :integer(11)   default(0)
#  mail              :text          
#  created_on        :datetime      
#

class Email < ActiveRecord::Base
end
