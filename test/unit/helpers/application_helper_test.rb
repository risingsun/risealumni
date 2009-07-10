require File.dirname(__FILE__) + '/../../test_helper'

class ApplicationHelperTest < ActionView::TestCase

  include ApplicationHelper

  def test_flickr_link
    fl = (Flickr.new(FLICKR_CACHE, FLICKR_KEY, FLICKR_SECRET).photos.search(nil, 'baby'))[0]
    f = flickr_link(fl)
    assert_not_nil f   
  end  
end
