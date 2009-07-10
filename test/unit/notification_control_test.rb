require File.dirname(__FILE__) + '/../test_helper'

class NotificationControlTest < ActiveSupport::TestCase
  
  should_belong_to :profile
  
  should_require_attributes :profile
  
end
