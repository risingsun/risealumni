require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < ActiveSupport::TestCase
  
  should_require_attributes :body, :subject, :sender, :receiver
  
  should_belong_to :receiver, :sender

  def test_should_delete_messages
    m = messages(:user_to_user2)
    p = profiles(:user)
    assert !m.delete_message(p.id)
  end
  
  
  def test_should_for_deleted_message
    m = messages(:delete_message)
    p = profiles(:user)
    assert m.delete_message(p.id)
  end
end
