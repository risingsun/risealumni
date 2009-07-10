require File.dirname(__FILE__) + '/../../test_helper'

class Admin::EventsControllerTest < ActionController::TestCase
  
  context 'on GET to :index' do
    setup do
      @request.session[:user] = users(:admin).id
      get :index
      assert_tag :tag => 'a', :attributes => {:href => admin_events_path}, :content => 'Events'
      assert_tag :tag => 'a', :attributes => {:href => feedbacks_path}, :content => 'Feedbacks'
    end

    should_assign_to :events
    should_respond_with :success
    should_render_template :index
  end
  
  context 'should render to login if user is not admin ' do
    setup do
      @request.session[:user] = users(:user).id
      get :index
      assert_no_tag :tag => 'a', :attributes => {:href => admin_events_path}, :content => 'Events'
      assert_no_tag :tag => 'a', :attributes => {:href => feedbacks_path}, :content => 'Feedbacks'
    end

    should_not_assign_to :events
  end

  
  context 'on get to :show' do
    setup do
      @request.session[:user] = users(:admin).id
      get :show, :id => events(:event1)
    end

    should_assign_to :event
    should_respond_with :success
    should_render_template :show
  end
  context 'on GET to :new' do
    setup do
      @request.session[:user] = users(:admin).id
      get :new
    end

    should_assign_to :event
    should_respond_with :success
    should_render_template :new
  end
  
  context 'on post to :create' do
    setup do
      @request.session[:user] = users(:admin).id
      post :create, :event => {:title => 'get together'}
    end

    should_assign_to :event
    should_set_the_flash_to "Event was successfully created."
    should_redirect_to "admin_events_path" 
  end
  
  context 'on post to not :create' do
    setup do
      @request.session[:user] = users(:admin).id
      post :create, :event => {}
    end
 
    should_assign_to :event
    should_set_the_flash_to "Event was not successfully created."
    should_respond_with :success
    should_render_template :new 
  end
  
  context 'on get to :edit' do
    setup do
      @request.session[:user] = users(:admin).id
      get :edit, :id => events(:event1)
    end

    should_assign_to :event
    should_respond_with :success
    should_render_template :edit
  end
  
  context 'on put to :update' do
    setup do
      @request.session[:user] = users(:admin).id
      put :update, :id => events(:event1), :event => {:title => 'school anniversary'}
    end

    should_assign_to :event
    should_set_the_flash_to "Event was successfully updated."
    should_redirect_to "admin_events_path" 
  end
  
  context 'on put to not :update' do
    setup do
      @request.session[:user] = users(:admin).id
      put :update, :id => events(:event1), :event => {:title => nil}
    end

    should_assign_to :event
    should_set_the_flash_to "Event was not successfully updated."
    should_respond_with :success
    should_render_template :edit 
  end
  
  context 'on delete to :destroy' do
    setup do
      @request.session[:user] = users(:admin).id
      delete :destroy, :id => events(:event1)
    end

    should_set_the_flash_to "Event was successfully deleted."
    should_redirect_to "admin_events_path" 
  end
  
  context 'on post to :send_event_mail' do
    setup do
      @request.session[:user] = users(:admin).id
      post :send_event_mail, :id => events(:event1)
    end

    should_set_the_flash_to "Mail was successfully sent"
    should_redirect_to "admin_events_path" 
  end
  
  context 'on Get to :Attending_members' do
    setup do
      @request.session[:user] = users(:user).id
      get :attending_members,:id => events(:event1)
    end
    should_respond_with :success
    should_render_template "shared/user_friends"
  end 
   context 'on Get to :Not Attending_members' do
    setup do
      @request.session[:user] = users(:user).id
      get :not_attending_members,:id => events(:event1)
    end
    should_respond_with :success
    should_render_template "shared/user_friends"
  end 
   context 'on Get to :May BeAttending_members' do
    setup do
      @request.session[:user] = users(:user).id
      get :may_be_attending_members,:id => events(:event1)
    end
    should_respond_with :success
    should_render_template "shared/user_friends"
  end 
  context 'on post to :RSVP' do
    setup do
      @request.session[:user] = users(:user).id
      post :rsvp,:id => events(:event1).id,:status => 'home page',:event_rsvp => 'Attending'
    end
    should_respond_with :success
  end 
  
  private
  
  def do_index_assertion
    
    assert_tag :tag => 'a', :attributes => {:href => admin_blogs_path}, :content => 'Blogs'
  end
  
end
