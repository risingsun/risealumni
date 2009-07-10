require "#{File.dirname(__FILE__)}/../test_helper"

class UserProfileTest < ActionController::IntegrationTest
  fixtures :all
 
  def test_truth
    user = user_message_test
    user.login
    user.get_messages
    user.try_to_create_message
    user.create_message
    user.sent_message
    user.show_sent_messages
    user.show_received_messages
    user.direct_message
    user.destroy_message
    user.delete_selected_message_from_inbox
    user.delete_selected_message_from_sent
    user.delete_selected_messages_from_sent
    user.delete_message_from_inbox_and_sent
  end
  def user_message_test
    open_session do |user|
      def user.login
        get "/login"
        assert_response :success
        post "/login", :user=>{:login => users(:user).login, :password => 'test'}
        assert_response :redirect
        assert session[:user]
        assert_redirected_to profile_path(assigns['u'].profile)
      end
      def user.get_messages
        get profile_messages_path(assigns(:u).profile) 
        assert_template 'index'
      end
      def user.try_to_create_message
        get new_profile_message_path(assigns(:p))
        assert_template 'new'
        post profile_messages_path(assigns(:p)),:message =>{}
        assert_equal(assigns(:message).errors.to_s,flash[:notice]) 
        assert_redirected_to new_profile_message_path(assigns(:p))
      end
      def user.create_message
        get new_profile_message_path(assigns(:u).profile)
        assert_template 'new'
        post profile_messages_path(assigns(:u).profile),:message =>{:receiver_id => profiles(:user2).id,:subject => 'hello',:body => 'How are you?'}
        assert_equal("Your Message has been sent.",flash[:notice])
        assert_response :redirect
      end
      def user.sent_message
        get sent_profile_messages_path(assigns(:p))
        assert_template 'sent'
      end
      def user.show_sent_messages
        get profile_message_path(assigns(:p),messages(:user_to_user2))
        assert_template 'show'
      end
      def user.show_received_messages
        get profile_message_path(assigns(:p),messages(:user2_to_user))
        assert_template 'show'
        get reply_message_profile_message_path(assigns(:p),assigns(:message))
        assert_response 200
        assert_template 'new'
      end
      def user.direct_message
        get direct_message_profile_messages_path(assigns(:p))
        assert_response 200
        assert_template 'new'
      end
      def user.destroy_message
        delete profile_message_path(assigns(:p),messages(:user2_to_user)) 
        assert_response :redirect
      end
      def user.delete_selected_message_from_inbox
        post delete_messages_profile_messages_path(assigns(:p)),:check => messages(:user2_to_user).id
        assert_response :redirect
      end
      def user.delete_selected_message_from_sent
        post delete_messages_profile_messages_path(assigns(:p)),:check => messages(:user_to_user2).id
        assert_response :redirect
      end
      def user.delete_selected_messages_from_sent
        post delete_messages_profile_messages_path(assigns(:p)),:check => [messages(:user_to_user2).id ,messages(:user_to_user2_message).id]
        assert_response :redirect
      end
      def user.delete_message_from_inbox_and_sent
        post delete_messages_profile_messages_path(assigns(:p)),:check => messages(:delete_message).id
        assert_response :redirect
      end
    end
  end
end