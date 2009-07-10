require File.dirname(__FILE__) + '/../test_helper'
class PollTest < ActiveSupport::TestCase
  should_have_many :poll_options,:poll_responses
  should_require_attributes :question, :profile
  should_belong_to :profile
  
  def test_responded
    poll = polls(:poll_1)
    p = profiles(:user)
    assert poll.responded?(p)
  end
  
  def test_not_responded
    poll = polls(:poll_1)
    p = profiles(:user4)
    assert !poll.responded?(p)
  end
 
  def test_can_not_edit
    poll = polls(:poll_1)
    assert !poll.can_edit?
  end
  def test_can_edit
    poll = polls(:poll_2)
    assert poll.can_edit?
  end
  def test_get_url
    poll = polls(:poll_1)
    assert_equal("http://chart.apis.google.com/chart?cht=bhg&chxt=y&chxl=0:|Gud|Easy|gems&chs=500x105&chd=t:33.3,33.3,33.3&chm=t 33.3%,000000,0,0,13|t 33.3%,000000,0,1,13|t 33.3%,000000,0,2,13&chco=3CD983|C4D925|BABF1B|BFA20F|A66D03|732C02",
                  poll.get_url)
  end
  def test_options_in_proper_order
    poll = polls(:poll_2)
    assert_not_nil poll.options_in_proper_order
  end
    
end
