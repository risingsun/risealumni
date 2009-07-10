require File.dirname(__FILE__) + '/../../test_helper'

class ProfilesHelperTest < ActionView::TestCase

  include ProfilesHelper
  
  def test_location_link
    @p = profiles(:user)
    assert_not_nil(location_link(@p))
  end
  
  def test_icon
    p = profiles(:user)
    assert_not_nil(icon(p))
  end
end
