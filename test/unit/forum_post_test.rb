require File.dirname(__FILE__) + '/../test_helper'

class ForumPostTest < ActiveSupport::TestCase
  
  should_require_attributes :body, :owner_id
  
  should_belong_to :owner
  should_belong_to :topic
  
end
