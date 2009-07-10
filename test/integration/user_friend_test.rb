require "#{File.dirname(__FILE__)}/../test_helper"

class UserFriendTest < ActionController::IntegrationTest
  # fixtures :your, :models

  # Replace this with your real tests.
  def test_truth
    user_should_login
    user_should_make_friend
    user_can_send_message
  end
  
  private
  
  def  user_should_login
    get "/login"
    assert_response :success
    post "/login", :user=>{:login => users(:user).login, :password => 'test'}
    assert_response :redirect
    assert session[:user]
    assert_redirected_to profile_path(assigns['u'].profile)
  end
  
  def user_should_make_friend
    user_should_follow_friend
    #friend_should_login
    friend_should_accept_request
  end
  
  def user_should_follow_friend
    post profile_friends_path(profiles(:user)), :profile_id=>profiles(:user).id, :id => profiles(:user2).id, :format=>'js'
    assert_response 500
  end
  
  def friend_should_accept_request
    post profile_friends_path(profiles(:user2)), :profile_id=>profiles(:user2).id, :id => profiles(:user).id, :format=>'js'
    assert_response 200
  end
  
  def user_can_send_message
    post profile_messages_path(profiles(:user)),:message => {:subject => 'test', :body => 'message', :receiver_id => profiles(:user2).id}
    assert_redirected_to :action => 'index'
  end
  
end
 