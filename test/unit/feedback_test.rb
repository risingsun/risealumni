require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < ActiveSupport::TestCase
  should_require_attributes :subject, :message
  should_belong_to :profile
  
  def test_to_require_email
    f1 = Feedback.new(:profile_id => nil)
    f2 = Feedback.new(:profile_id => 1, :email => 'rays.rashmi@gmail.com', :name => 'rashmi', :message => 'message', :subject => 'sss')  
    assert !f1.valid?
    assert f2.valid?
  end
  
  def test_to_require_name
    f1 = Feedback.new(:profile_id => 1, :email => 'rays.rashmi@gmail.com', :message => 'message', :subject => 'sss')
    assert f1.valid?
    f2 = Feedback.new( :email => 'rays.rashmi@gmail.com', :message => 'message', :subject => 'sss')
    assert !f2.valid?  
  end
  
  def test_should_call_after_save 
    f = Feedback.new(:profile_id => 1, :email => 'anuraag.jpr@gmail.com', :name => 'anurag', :message => 'test message', :subject => 'test subject')
    assert f.save
  end
end
