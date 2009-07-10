require File.dirname(__FILE__) + '/../test_helper'

class ProfileEventTest < ActiveSupport::TestCase
  should_belong_to :profile,:event  
  should_require_attributes :role,:profile,:event
  should_require_unique_attributes :profile_id, :scoped_to => :event_id, :message => 'has already.'
  
  def test_is_organizer
    pe = profile_events(:one)
    assert pe.is_organizer?
  end
  
end
