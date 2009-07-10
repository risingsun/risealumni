require File.dirname(__FILE__) + '/../test_helper'

class CommentsControllerTest < ActionController::TestCase
  
  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  
  context 'on GET to :index' do
    should "render action when logged in as :owner and viewing :user" do
      p = profiles(:user2)
      get :index, {:profile_id => p.id}, {:user => profiles(:user).id}
      assert_not_nil assigns(:comments)
      assert_not_nil assigns(:parent)
      assert_not_nil assigns(:profile)
      assert !assigns(:comments).empty?
      assert_response :success
      assert_template 'index'
      #assert_tag :tag => 'a', :content => '&larr; Back to Profile', :attributes => {:href => profile_path(p)}
    end
    
    should "redirect to home_path when not logged" do
      p = profiles(:user2)
      get :index, {:profile_id => p.id}
      assert_response :redirect
      assert_redirected_to login_path
    end
  end
  
  context 'on POST to :create' do
    should "render action when logged in as :owner on blog" do
      p = profiles(:user)
      b = p.blogs.first
      assert_difference "Comment.count" do
        post :create, {:blog_id => b.id, :profile_id => p.id,  :format => 'js', :comment => {:comment => 'test'}}, {:user => p.id}
        assert_not_nil assigns(:profile)
        assert_not_nil assigns(:blog)
        assert_not_nil assigns(:comment)
      end
    end
    
    should "render action when logged in as :owner on profile" do
      p = profiles(:user)
      assert_difference "Comment.count" do
        post :create, {:profile_id => p.id,  :format => 'js', :comment => {:comment => 'test'}}, {:user => p.id}
        assert_not_nil assigns(:profile)
        assert_nil assigns(:blog)
        assert_not_nil assigns(:comment)
      end
    end
    
    should "render action when logged in as :user on blog" do
      p = profiles(:user)
      b = p.blogs.first
      assert_difference "Comment.count" do
        post :create, {:blog_id => b.id, :format => 'js', :comment => {:comment => 'test'}}, {:user => profiles(:user2).id}
        assert_not_nil assigns(:parent)
        assert_not_nil assigns(:blog)
        assert_not_nil assigns(:comment)
      end
    end
    
    should "render action with bad data when logged in as :user on blog" do
      p = profiles(:user)
      b = p.blogs.first
      assert_no_difference "Comment.count" do
        post :create, {:profile_id => p.id, :blog_id => b.id, :format => 'js', :comment => {:comment => ''}}, {:user => profiles(:user2).id}
        assert_not_nil assigns(:comment)
        assert !assigns(:comment).save
      end
    end
  end
  
  context 'on Delete to :Destroy' do
    should 'delete comments' do
      p = profiles(:user)
      delete :destroy, {:profile_id => p.id, :id => comments(:second)}, {:user => profiles(:user).id}
      assert_redirected_to profiles_path
    end
    
     should 'delete comments :render to js format' do
      p = profiles(:user)
      delete :destroy, {:profile_id => p.id, :id => comments(:second),:format => 'js'}, {:user => profiles(:user).id} 
      #assert_redirected_to profiles_path
      assert_response :success      
    end
    
    should "not delete comments when not logged in" do
      p = profiles(:user)
      delete :destroy, {:profile_id => p.id, :id => comments(:second)}
      assert_redirected_to login_path
    end
    
    should "not delete comments when logged in as :user" do
      p = profiles(:user)
      delete :destroy, {:profile_id => p.id, :id => comments(:eight)}, {:user => profiles(:user4).id}
      assert_redirected_to profiles_path
    end
  end
end
