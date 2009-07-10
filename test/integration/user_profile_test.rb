require "#{File.dirname(__FILE__)}/../test_helper"

class UserProfileTest < ActionController::IntegrationTest
  fixtures :all
 
  def test_truth
    user = user_test
    user.try_to_login
    user.login
    user.view_profile
    user.try_to_edit_profile
    user.edit_profile
    user.edit_permission
    user.try_to_request_new_email_with_invalid_format
    user.request_new_email
    user.try_to_change_password
    user.change_password
    user.add_comments
  end
  
  private
 
  def user_test  
    open_session do |user|
      def user.try_to_login
        get "/login"
        assert_response :success
        post "/login", :user=>{:login => 'test failure', :password => 'test failure'}
        assert_nil session[:user]
      end
      def user.login
        get "/login"
        assert_response :success
        post "/login", :user=>{:login => users(:user).login, :password => 'test'}
        assert_response :redirect
        assert session[:user]
        assert_redirected_to profile_path(assigns['u'].profile)
      end
      def user.view_profile
        get profile_path(assigns(:u).profile)
        assert_template 'show'
      end
      def user.try_to_edit_profile
        get edit_profile_path(assigns(:p))
        assert_template 'edit'
        put profile_path(assigns(:p)),:profile => {:first_name => nil},:switch =>'profile'
        #assert flash.now[:error] = assigns(:profile).errors
        assert_template 'edit'
      end
      def user.edit_profile
        get edit_profile_path(assigns(:p))
        assert_template 'edit'
        put profile_path(assigns(:p)),:profile => {:first_name => 'Pooja'},:switch =>'profile'
        assert flash[:notice] = "Settings have been saved."
        assert_redirected_to edit_profile_path(assigns(:profile))
      end
      
      def user.edit_permission
        get edit_account_profile_path(assigns(:p))
        assert_template 'edit_account'
        put profile_path(assigns(:p)),:profile => {:email =>'Myself'},:switch => 'permissions'
        assert flash[:notice] = "Settings have been saved."
        assert_redirected_to edit_account_profile_url(assigns(:profile))
      end
      
      def user.try_to_request_new_email_with_invalid_format
        get edit_account_profile_path(assigns(:p))
        assert_template 'edit_account'
        put profile_path(assigns(:p)), :switch => 'request_email',:user => {:requested_new_email => 'pooja.gupta@gmail'}
        #assert flash.now[:error] = assigns(:user).errors
      end
      
      def user.request_new_email
        get edit_account_profile_path(assigns(:p))
        assert_template 'edit_account'
        put profile_path(assigns(:p)), :switch => 'request_email',:user => {:requested_new_email => 'pooja.gupta@gmail.com'}
        assert flash[:notice] = "Email change request has been sent at your email."
        assert_redirected_to edit_account_profile_url(assigns(:profile))
      end
    
      def user.try_to_change_password
        get edit_account_profile_path(assigns(:p))
        assert_template 'edit_account'
        put profile_path(assigns(:p)), :switch => 'request_email',:user => {:verify_password => 'test',:new_password=>'123456',:confirm_password => '1234561233344'}
        #assert flash.now[:error] = assigns(:user).errors
      end
      def user.change_password
        get edit_account_profile_path(assigns(:p))
        assert_template 'edit_account'
        put profile_path(assigns(:p)), :switch => 'password', :verify_password => 'test',:new_password=>'123456',:confirm_password => '123456'
        assert flash[:notice] = "Password has been changed."
        assert_redirected_to edit_account_profile_url(assigns(:profile))
      end
       def user.set_default_permissions
        get edit_account_profile_path(assigns(:p))
        assert_template 'edit_account'
        put profile_path(assigns(:p)),:profile => {:default_permission => 'Myself'}
        assert flash[:notice] = "Settings have been saved."
        assert_response :redirect
      end
      def user.add_comments
        p = assigns(:p)
        b = p.blogs.first
        post profile_comments_path(assigns(:u)), {:profile_id => assigns(:p),  :format => 'js', :comment => {:comment => 'test'}}
      end
    end
  end 
end