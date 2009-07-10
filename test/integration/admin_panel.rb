require "#{File.dirname(__FILE__)}/../test_helper"

class AdminPanelTest < ActionController::IntegrationTest
  fixtures :all
  def test_truth
    admin = admin_test
    admin.login
    admin.show_users
    admin.actived_to_user
    admin.deactived_to_user
    admin.try_to_create_event
    admin.create_event
    admin.show_event
    admin.edit_event
    admin.delete_event
  end
  def admin_test
    open_session do |admin|
      def admin.login
        get "/login"
        assert_response :success
        post "/login", :user=>{:login => users(:admin).login, :password => 'test'}
        assert_response :redirect
        assert session[:user]
        assert_redirected_to profile_path(assigns['u'].profile)
      end
      def admin.show_users
        get admin_users_path()
        assert_response :success
        assert_template 'index'
      end
      def admin.actived_to_user
        put admin_user_path(profiles(:inactive))
        assert_response :success
      end
      def admin.deactived_to_user
        put admin_user_path(profiles(:user2))
        assert_response 200
      end
      def admin.get_events
        get admin_events_path()
        assert_template 'index'
      end
      def admin.try_to_create_event
        get new_admin_event_path()
        assert_response :success
        post admin_events_path()
        assert_equal('Event was not successfully created.',flash[:notice])
        assert_template 'new'
      end
      def admin.create_event
        get new_admin_event_path()
        assert_response :success
        post admin_events_path(),:event => {:title => 'For event'}
        assert_equal('Event was successfully created.',flash[:notice])
        assert_redirected_to admin_events_path
      end
      def admin.show_event
        get admin_event_path(events(:event1))
        assert_response :success
      end
      def admin.edit_event
        get edit_admin_event_path(events(:event1))
        assert_response :success
        put admin_event_path(events(:event1)),:event => {:title => 'We will organized a event'}
        assert_equal('Event was successfully updated.',flash[:notice])
        assert_redirected_to admin_events_path 
      end
      def admin.delete_event
        delete admin_event_path(events(:event1).id)
        assert_equal('Event was successfully deleted.',flash[:notice])
        assert_response :redirect
      end
    end
  end
end
