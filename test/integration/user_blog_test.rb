require "#{File.dirname(__FILE__)}/../test_helper"

class UserBlogTest < ActionController::IntegrationTest
  fixtures :all
 
  def test_truth
    user = user_blog_test
    user.login
    user.get_blogs
    user.get_another_user_blogs
    user.try_to_create_blog
    user.create_blog
    user.try_to_edit_blog
    user.edit_blog
    user.destroy_blog
    user.create_public_blog
  end
  
  def user_blog_test
    open_session do |user|
      def user.login
        get "/login"
        assert_response :success
        post "/login", :user=>{:login => users(:user).login, :password => 'test'}
        assert_response :redirect
        assert session[:user]
        assert_redirected_to profile_path(assigns['u'].profile)
      end
      def user.get_blogs
        get profile_blogs_path(assigns(:u).profile)
        assert_template 'index'
      end
      def user.get_another_user_blogs
        get profile_blogs_path(profiles(:user2))
        assert_template 'index'
      end
      def user.try_to_create_blog
        get new_profile_blog_path(assigns(:p))
        assert_template 'new'
        post profile_blogs_path(assigns(:p)),:blog =>{}
        assert_equal('Failed to create a new blog post.',flash.now[:error]) 
        assert_template 'new'
      end
      def user.create_blog
        get new_profile_blog_path(assigns(:p))
        assert_template 'new'
        post profile_blogs_path(assigns(:p)),:blog =>{:title => "AAAA", :body => "BBBBB", :profile_id => assigns(:p).id}
        assert_equal('New blog post created.',flash[:notice]) 
        assert_redirected_to profile_blogs_path(assigns(:p))
      end
      def user.try_to_edit_blog
        get edit_profile_blog_path(assigns(:p),blogs(:first))
        assert_template 'edit'
        put profile_blog_path(assigns(:p)),:blog =>{:title => "CCC", :body => nil, :profile_id => assigns(:p).id}
        assert_equal('Failed to update the blog post.',flash.now[:error]) 
        assert_template 'edit'
      end
      def user.edit_blog
        get edit_profile_blog_path(assigns(:p),blogs(:first))
        assert_template 'edit'
        put profile_blog_path(assigns(:p)),:blog =>{:title => "CCC", :body => "DDDDDDD", :profile_id => assigns(:p).id}
        assert_equal('Blog post updated.',flash[:notice]) 
        assert_redirected_to profile_blogs_path(assigns(:p))
      end
      def user.destroy_blog
        delete profile_blog_path(assigns(:p),blogs(:second))
        assert_redirected_to profile_blogs_path(assigns(:p))
      end
      def user.create_public_blog
        get new_profile_blog_path(assigns(:p))
        assert_template 'new'
        post profile_blogs_path(assigns(:p)),:blog =>{:title => "AAAA", :body => "BBBBB", :profile_id => assigns(:p).id, :public => true}
        assert assigns(:blog).public
        assert_equal('New blog post created.',flash[:notice]) 
        assert_redirected_to profile_blogs_path(assigns(:p))
      end
    end
  end
end