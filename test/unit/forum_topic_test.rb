require File.dirname(__FILE__) + '/../test_helper'

class ForumTopicTest < ActiveSupport::TestCase
  
  include ForumsTestHelper
  
  should_require_attributes :title, :forum_id, :owner_id
  
  should_belong_to :forum, :owner
  should_have_many :posts
  
  should "create a feed item" do
    topic = ForumTopic.new(valid_forum_topic_attributes)
    topic.save!
  end
  
end
