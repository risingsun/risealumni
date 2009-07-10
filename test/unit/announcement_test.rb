require File.dirname(__FILE__) + '/../test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  
  should_require_attributes :starts_at, :ends_at , :message
  
  
  def test_should_find_current_announcments
    assert Announcement.current_announcements(Time.now)
  end
  
end
