require File.dirname(__FILE__) + '/../test_helper'

class MarkerTest < ActiveSupport::TestCase
  
  should_require_attributes :lat,:lng
  should_have_one :profile,:event
 
end
