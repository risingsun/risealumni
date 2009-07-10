require File.dirname(__FILE__) + '/../test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  
  context 'on GET to :index' do
    setup do
      @request.session[:user] = users(:admin).id
      get :index
    end
    should_assign_to :feedbacks  
    should_respond_with :success
    should_render_template :index
  end
  
  context 'on GET to :index while not logged in' do
    setup do
      get :index
    end
    should_not_assign_to :feedbacks
    should_redirect_to 'login_path'
  end
  
  context 'on get to :show' do
    setup do
      @request.session[:user] = users(:admin).id
      get :show, :id => feedbacks(:feedback1)
    end

    should_assign_to :feedback
    should_respond_with :success
    should_render_template :show
  end
  
  context 'on GET to :show while not logged in ' do
    setup do
      get :show, :id => feedbacks(:feedback1)
    end
    should_not_assign_to :feedback
    should_redirect_to 'login_path'
  end
  
  context 'on GET to :new ' do
    should 'get new without logged in' do
      get :new
      assert_response :success
      assert_template 'new'
      new_assertions
      assert_tag :tag => 'input', :attributes => {:class => 'text_field', :id => 'feedback_name'}
      assert_tag :tag => 'input', :attributes => {:class => 'text_field', :id => 'feedback_email'}      
    end
    
    should 'get new while logged in' do
      @request.session[:user] = users(:user).id
      get :new, :user => users(:user)
      assert_response :success
      assert_template 'new'
      new_assertions
      assert :tag => 'input', :attributes => {:class => 'text_field', :id => 'feedback_subject'}
      assert :tag => 'textarea', :attributes => {:class => 'text_area', :id => 'feedback_message'}
    end
  end
  
 
  context 'on post to :create' do
    setup do
      @request.session[:user] = users(:admin).id
      post :create, :feedback => { :message => 'Nice',:subject => 'feedback'}
    end

    should_assign_to :feedback
    should_set_the_flash_to "Thank you for your message.  A member of our team will respond to you shortly."
    should_redirect_to 'home_path'
  end  
  
  context 'on post to :create but not logged in' do
    setup do
      post :create, :feedback => {:name => 'pooja', :message => 'Nice',:email => 'pooja@gmail.com',:subject => 'feedback',:captcha => 'hijklm',:captcha_answer => 'hijklm'}
    end

    should_assign_to :feedback
    #should_set_the_flash_to "Thank you for your message.  A member of our team will respond to you shortly."
    #should_redirect_to 'home_path'
  end
  
  context 'on post to not :create' do
    setup do
      @request.session[:user] = users(:admin).id
      post :create, :feedback => {}
    end
    should_assign_to :feedback
    should_respond_with :success
    should_render_template :new
  end
    
  context 'on delete to :destroy' do
    setup do
      @request.session[:user] = users(:admin).id
      delete :destroy, :id => feedbacks(:feedback1)
    end
    should_redirect_to "feedbacks_path"  
  end
  
  context 'on delete to :destroy(not logged in)' do
    setup do
      delete :destroy, :id => feedbacks(:feedback1)
    end
    should_redirect_to "login_path"  
  end
  
  private
  
  def new_assertions
    assert_tag :tag => 'form', :attributes => {:action => feedbacks_path}
    assert_tag :tag => 'label', :attributes => {:class => 'label_margin'}
    assert :tag => 'input', :attributes => {:class => 'button_large_button', :type => 'submit'}
  end
  
  def index_assertions
    assert_tag :tag => 'a', :attributes => {:href => feedback_path(assigns(:feedback))}
    assert_tag :tag => 'a', :attributes => {:href => feedback_path(assigns(:feedback)), :method => :delete}
  end
  
  
end
