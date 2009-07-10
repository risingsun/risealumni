require File.dirname(__FILE__) + '/../test_helper'

class PollResponseTest < ActiveSupport::TestCase
  
  should_require_attributes :profile,:poll_option,:poll_id
  should_belong_to :profile,:poll_option,:poll
  should_require_unique_attributes :profile_id, :scoped_to => :poll_id, :message => 'has already voted.'
  
  def test_update_poll_votes_count
    poll_response = PollResponse.create(:profile => profiles(:admin),:poll_option => poll_options(:option1),:poll => polls(:poll_1))
    assert_equal(4,poll_response.poll.votes_count)
  end
end
