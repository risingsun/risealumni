require File.dirname(__FILE__) + '/../test_helper'

class VotesControllerTest < ActionController::TestCase
  def setup
    @request    = ActionController::TestRequest.new
  end
 
  def test_should_post_poll
    @request.session[:user] = users(:admin).id
    post :create, :votes => { :poll_option =>  polls(:poll_1).id }
    assert_response :success
  end
end
