require File.dirname(__FILE__) + '/../test_helper'

class PollOptionTest < ActiveSupport::TestCase

  should_belong_to :poll
  should_have_many :poll_responses
  should_require_unique_attributes :option, :scoped_to => :poll_id, :message => 'has already.'
  
  def test_votes_percentage
    poll_option = poll_options(:option1)
    assert_equal("33.3",poll_option.votes_percentage)
  end
  
 

end
