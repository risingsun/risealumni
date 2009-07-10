require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  should_require_attributes :title
  should_belong_to :marker
  should_have_many :profile_events,:comments
  should_have_many :profiles,:organizers,
                   :attending,:not_attending,
                   :may_be_attending, :through => :profile_events
                 
  def test_list
    e = events(:event1)
    assert_not_nil e.list('Attending')
  end
  
  def test_responded
    e = events(:event1)
    p = profiles(:user)
    assert e.responded?(p)
  end
  
  def test_set_organizer
    e = events(:event1)
    p = profiles(:user2)
    assert e.set_organizer(p)
  end
  def test_new_marker
    e = events(:event1)
    assert e.marker=({:lat => '26.8906122660',:lng => '75.8012866974'})
  end
  def test_destroy_marker
    e = events(:event1)
    assert e.marker=({:lat => '0',:lng => '0'})
  end
 
end