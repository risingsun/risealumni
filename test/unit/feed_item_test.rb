require File.dirname(__FILE__) + '/../test_helper'

class FeedItemTest < ActiveSupport::TestCase
  should_belong_to :item
  should_have_many :feeds
  
  should 'partial' do
    f = feed_items(:one)
    assert_not_nil f.partial
  end
end
