require File.dirname(__FILE__) + '/../test_helper'

class BlogsControllerTest < ActionController::TestCase

  VALID_BLOG_POST = {
    :title => 'Valid Blog Post',
    :body => 'This is a valid blog post.'
  }
  
  OWNER_LINKS = ['(edit)', '(delete)']
  
  def setup
    @controller = BlogsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'on GET to :show' do
    should "render action when logged in as :owner" do
      do_show_assertions users(:user).id
      assert_tag :tag => 'a', :attributes => {:href => new_profile_blog_path(assigns(:p))}
    end
    
    should "render action when logged in as :user" do
      do_show_assertions users(:user2).id
      #assert_tag :tag => 'a', :attributes => {:href => new_profile_comment_path(assigns(:p))}
    end
  end 
  
  context 'on Get to :index' do
    
    should" render to new blog " do
      @request.session[:user] = users(:user3).id
      get :index, :profile_id => profiles(:user3).id, :user => profiles(:user3).id
      assert_equal 'You have not create any blog posts. Try creating one now.', flash[:notice]
      assert_redirected_to new_profile_blog_path(profiles(:user3))  
    end
    
    should " render to index template" do
      @request.session[:user] = users(:user).id
      get :index, :profile_id => profiles(:user).id, :user => profiles(:user).id
      assert_response :success
      assert_template 'index'
      do_index_assertion
    end
  
    should'render to index (p & profile are not same)' do
      @request.session[:user] = users(:user2).id
      get :index, :profile_id => profiles(:user).id, :user => profiles(:user2).id
      assert_response :success
      assert_template 'index'
      assert_no_tag :tag => 'a', :attributes => {:href =>  new_profile_blog_path(assigns(:profile))}
      
    end
    
  end
  
  context 'on GET to :new' do
    should "render action when logged in as :owner" do
      p = profiles(:user)
      get :new, {:profile_id => p.id}, {:user => p.user.id}
      #assert_not_nil assigns(:blogs)
      assert assigns(:blog).new_record?
      assert_equal p, assigns(:profile)
      assert_equal Hash.new, flash
      assert_template 'new'
      assert_response :success
      assert_tag :tag => 'div', :children => {:count => 2}
      #assert_tag :content => '&larr; Back to Blogs', :attributes => {:href=>profile_blogs_path(p)}
    end
    
    should "redirect to home_path when logged in as :user" do
      p = profiles(:user)
      get :new, {:profile_id => p.id}, {:user => users(:user2).id}
      assert_nil assigns(:blogs)
      assert_equal 'It looks like you don\'t have permission to view that page.', flash[:error]
      assert_response :redirect
      assert_redirected_to home_path
    end
    
    should "redirect to login_path when not logged in" do
      p = profiles(:user)
      get :new, {:profile_id => p.id}
      assert_nil assigns(:blogs)
      assert_response :redirect
      assert_redirected_to login_path
    end
  end
  
  context 'on GET to :edit' do
    should "render action when logged in as :owner" do
      p = profiles(:user)
      b = p.blogs.first
      get :edit, {:profile_id => p.id, :id => b.id}, {:user => p.user.id}
      #assert_not_nil assigns(:blogs)
      assert_equal b, assigns(:blog)
      assert_equal p, assigns(:profile)
      assert_equal Hash.new, flash
      assert_template 'edit'
      assert_response :success
      #assert_tag :content => '&larr; Back to Dashboard', :attributes => {:href=>profile_path(p)}
      #assert_tag :content => '&larr; Back to Blogs', :attributes => {:href=>profile_blogs_path(p)}
    end
    
    should "redirect to home_path when logged in as :user" do
      p = profiles(:user)
      b = p.blogs.first
      get :edit, {:profile_id => p.id, :id => b.id}, {:user => users(:user2).id}
      assert_equal 'It looks like you don\'t have permission to view that page.', flash[:error]
      assert_response :redirect
      assert_redirected_to home_path
    end
    
    should "redirect to login_path when not logged in" do
      p = profiles(:user)
      b = p.blogs.first
      get :new, {:profile_id => p.id, :id => b.id}
      assert_response :redirect
      assert_redirected_to login_path
    end
  end
  
  context 'on POST to :create' do
    should "render to new action when preview" do
      p = profiles(:user)
      post :create, {:profile_id => p.id, :blog => VALID_BLOG_POST,:preview_button => "preview_button"}, {:user => p.user.id} 
      assert assigns(:blog)
      assert_response :success
    end
    should "redirect to profil_blogs_path with new blog when logged in as :owner" do
      p = profiles(:admin)
      assert_difference "Blog.count" do
        post :create, {:profile_id => p.id, :blog => VALID_BLOG_POST}, {:user => p.user.id}
        assert_contains flash[:notice], /created/
        assert_response :redirect
        assert_redirected_to profile_blogs_path(p)
      end
    end
    
    should "render :new with error when logged in as :owner" do
      p = profiles(:user)
      assert_no_difference "Blog.count" do
        post :create, {:profile_id => p.id, :blog => VALID_BLOG_POST.merge(:body => '')}, {:user => p.user.id}
        assert_response :success
        assert_template 'new'
        assert assigns(:blog).new_record?
        assert !assigns(:blog).errors.empty?
      end
    end
    
    should "redirect to home_path when logged in as :user" do
      p = profiles(:user)
      post :create, {:profile_id => p.id, :blog => VALID_BLOG_POST}, {:user => users(:user2).id}
      assert_equal 'It looks like you don\'t have permission to view that page.', flash[:error]
      assert_response :redirect
      assert_redirected_to home_path
    end
    
    should "redirect to login_path when not logged in" do
      p = profiles(:user)
      post :create, {:profile_id => p.id, :blog => VALID_BLOG_POST}
      assert_response :redirect
      assert_redirected_to login_path
    end
  end
  
  context 'on PUT to :update' do
    should "render to edit action when preview" do
      p = profiles(:user)
      b = p.blogs.first
      put :update, {:profile_id => p.id, :id=> b.id, :blog => VALID_BLOG_POST,:preview_button => "preview_button"}, {:user => p.user.id}
      assert assigns(:blog)
      assert_response :success
    end
 
    should "redirect to profil_blogs_path with blog when logged in as :owner" do
      p = profiles(:user)
      b = p.blogs.first
      put :update, {:profile_id => p.id, :id=>b.id, :blog => VALID_BLOG_POST}, {:user => p.user.id}
      assert_contains flash[:notice], /updated/
      assert_response :redirect
      assert_redirected_to profile_blogs_path(p)
    end
    
    should "render :edit with error when logged in as :owner" do
      p = profiles(:user)
      b = p.blogs.first
      put :update, {:profile_id => p.id, :id=>b.id, :blog => VALID_BLOG_POST.merge(:title => '')}, {:user => p.user.id}
      assert_response :success
      assert_template 'edit'
      assert !assigns(:blog).errors.empty?
    end
    
    should "redirect to home_path when logged in as :user" do
      p = profiles(:user)
      b = p.blogs.first
      put :update, {:profile_id => p.id, :id=>b.id, :blog => VALID_BLOG_POST}, {:user => users(:user2).id}
      assert_equal 'It looks like you don\'t have permission to view that page.', flash[:error]
      assert_response :redirect
      assert_redirected_to home_path
    end
    
    should "redirect to login_path when not logged in" do
      p = profiles(:user)
      b = p.blogs.first
      put :update, {:profile_id => p.id, :id=>b.id, :blog => VALID_BLOG_POST}
      assert_response :redirect
      assert_redirected_to login_path
    end
  end
  
  context 'on DELETE to :destroy' do
    should "redirect to profil_blogs_path after deleting when logged in as :owner" do
      assert_difference "Blog.count", -1 do
        p = profiles(:user)
        b = p.blogs.first
        delete :destroy, {:profile_id => p.id, :id=>b.id}, {:user => p.user.id}
        assert_contains flash[:notice], /deleted/
        assert_response :redirect
        assert_redirected_to profile_blogs_path(p)
      end
    end
    
    should "redirect to home_path when logged in as :user" do
      p = profiles(:user)
      b = p.blogs.first
      put :destroy, {:profile_id => p.id, :id=>b.id}, {:user => users(:user2).id}
      assert_equal 'It looks like you don\'t have permission to view that page.', flash[:error]
      assert_response :redirect
      assert_redirected_to home_path
    end
    
    should "redirect to login_path when not logged in" do
      p = profiles(:user)
      b = p.blogs.first
      put :destroy, {:profile_id => p.id, :id=>b.id}
      assert_response :redirect
      assert_redirected_to login_path
    end
  end
  
  
  protected
  
  def do_show_assertions session_user_id = nil
    p = profiles(:user)
    b = profiles(:user).blogs.last
    get :show, {:profile_id => p.id, :id => b.id}, {:user => session_user_id}
    #assert_not_nil assigns(:blogs)
    assert_equal b, assigns(:blog)
    assert_equal p, assigns(:profile)
    assert_equal Hash.new, flash
    assert_template 'show'
    assert_response :success
    assert_tag :tag => 'div', :children => {:count => 1, :only => {:tag => 'h2'}}
    assert_tag :tag => 'h2', :attributes => {:class=>'page_title'}
    
  end
  
  def do_index_assertion
    assert_tag :tag => 'a', :attributes => {:href =>  new_profile_blog_path(assigns(:profile))}
    assert_tag :tag => 'a',:attributes => {:href =>  edit_profile_blog_path(assigns(:profile), blogs(:first))}
    assert_tag :tag => 'a',:attributes => {:href =>  profile_blog_path(assigns(:profile), blogs(:first))}
  end
  
end