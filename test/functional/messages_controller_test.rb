require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase

  context 'get the index' do
    should "render to index template" do
      @request.session[:user] = users(:user).id
      get :index, :profile_id => profiles(:user).id
      assert assigns(:p)
      assert_template 'index'
      do_index_assertion
    end
    
    should "render to new message page" do
      @request.session[:user] = users(:user5).id
      get :index, :profile_id => profiles(:user5).id
      assert_redirected_to new_profile_message_path(users(:user5).profile)
    end
    
    should " render to index when not having friends" do
      @request.session[:user] = users(:user3).id
      get :index, :profile_id => profiles(:user3).id
      assert_equal('You cannot send messages',flash[:notice])
      assert_template 'index'
    end
    
    should " render to index when user is not activated" do
      @request.session[:user] = users(:inactive).id
      get :index, :profile_id => profiles(:inactive).id
      assert_equal('You cannot send messages',flash[:notice])
      assert_template 'index'
    end
    
    
    should "render to index when not having messages in sent " do
      @request.session[:user] = users(:user4).id
      get :index, :profile_id => profiles(:user4).id
      assert_template 'index'
      do_index_assertion
    end
  end
    
  should "get the show message page" do
    assert_nothing_raised do
      @request.session[:user] = users(:user).id
      get :show, :id => messages(:user2_to_user).id , :profile_id => profiles(:user).id
      assert_response 200
      assert_template 'show'
    end
  end


  should "get the show message page (security redirect)" do
    assert_nothing_raised do
      @request.session[:user] = users(:user).id
      get :show, :id => messages(:user_to_user2), :profile_id => profiles(:user).id
      assert_response 200
      assert_template 'show'
    end
  end
  
  should "not get the show message page " do
    assert_nothing_raised do
      @request.session[:user] = users(:user3).id
      get :show, :id => messages(:user_to_user2), :profile_id => profiles(:user3).id
      assert_equal('It looks like you don\'t have permission to view that page.',flash[:error])
      assert_redirected_to profile_messages_path(assigns(:p))
    end
  end


  should "get sent messages" do
    assert_nothing_raised do
      @request.session[:user] = users(:user2).id
      get :sent, :user => users(:user2), :profile_id => profiles(:user2).id
      assert_response 200
      assert_template 'sent'
    end
  end
  should "direct messages" do
    assert_nothing_raised do
      @request.session[:user] = users(:user2).id
      get :direct_message,:profile_id => profiles(:user2).id
      assert_response 200
      assert_template 'new'
    end
  end
  should "reply messages" do
    assert_nothing_raised do
      @request.session[:user] = users(:user2).id
      get :reply_message,:profile_id => profiles(:user2).id,:id => messages(:user_to_user2).id
      assert_response 200
      assert_template 'new'
    end
  end

  

  context 'create a new message' do
    should " get new message " do
      @request.session[:user] = users(:user).id
      get :new, :profile_id => profiles(:user).id
      assert_response :success
      do_new_assertion
    end
    
    should " not create new message if there is no network" do
      @request.session[:user] = users(:user6).id
      get :new, :profile_id => profiles(:user6).id
      assert !assigns(:p).has_network?
      assert_redirected_to :action => 'index'
    end
  
    should " not create new message if user is not inactive" do
      @request.session[:user] = users(:inactive).id
      get :new, :profile_id => profiles(:inactive).id
      assert !assigns(:p).can_send_messages
      assert_redirected_to :action => 'index'
    end
    
    should "  create new message if user is active" do
      @request.session[:user] = users(:user2).id
      get :new, :profile_id => profiles(:user2).id
      assert assigns(:p).can_send_messages
      assert_response :success
    end
  end

  
  context " should handle POST/creat" do
    should "create a new message" do
      assert_nothing_raised do
        assert_difference "Message.count" do
          @request.session[:user] = users(:user).id
          post :create, {:profile_id => profiles(:user).id, :message => {:subject => 'test', :body => 'message', :receiver_id => profiles(:user2).id, :sender_id => profiles(:user)}}, {:user => profiles(:user).id}
          assert_redirected_to :action => 'index'
        end
      end
    end
  
    should "not create new message" do
      assert_no_difference "Message.count" do
        @request.session[:user] = users(:user).id
        post :create, {:profile_id => profiles(:user).id, :message => {:receiver_id => profiles(:user2).id}}, {:user => profiles(:user).id}
        assert_redirected_to new_profile_message_path(profiles(:user))
      end
    end

    should "not create a new message (no can_send)" do
      assert_nothing_raised do
        assert_no_difference "Message.count" do
          @request.session[:user] = users(:user).id
          post :create, {:profile_id => profiles(:cant_message).id, :message => {:subject => '', :body => ''}}, {:user => profiles(:cant_message).id}
          assert_response 200
          assert_match "Cuz you sux", @response.body
        end
      end
    end
  end

  context 'delete message' do
    should "destroy message" do
      @request.session[:user] = users(:user).id
      delete :destroy, :profile_id => profiles(:user).id,:id => messages(:user2_to_user).id
      assert_response :redirect
    end
    
    should "delete message from inbox" do
      @request.session[:user] = users(:user).id
      post :delete_messages, :profile_id => profiles(:user).id,:check => messages(:user2_to_user).id
      assert_response :redirect
    end
    
    should "delete message from sent" do
      @request.session[:user] = users(:user).id
      post :delete_messages, :profile_id => profiles(:user).id,:check => messages(:user_to_user2).id
      assert_response :redirect
    end
    
    should "delete more then one message from sent" do
      @request.session[:user] = users(:user).id
      post :delete_messages, :profile_id => profiles(:user).id,:check => [messages(:user_to_user2).id ,messages(:user_to_user2_message).id]
      assert_response :redirect
    end
    should "delete  message from sent and inbox" do
      @request.session[:user] = users(:user).id
      post :delete_messages, :profile_id => profiles(:user).id,:check => messages(:delete_message).id 
      assert_response :redirect
    end
  end
  
  private
  
  def do_new_assertion
    assert_tag :tag => 'form', :attributes => {:action =>  profile_messages_path(profiles(:user)) }
    assert_tag :tag => 'select', :attributes => {:class => 'big_text_field', :name => 'message[receiver_id]' }
    assert_tag :tag => 'input', :attributes => {:type => 'text',:name => 'message[subject]', :title => 'Subject'}
    assert_tag :tag => 'textarea', :attributes => { :name => 'message[body]', :title => 'Body'}
    assert_tag :tag => 'img', :attributes => {:alt => 'Send-message'}
  end
  
  def do_index_assertion
    assert_tag :tag => 'form',:attributes => {:action =>  delete_messages_profile_messages_path(assigns(:p)) }
  end
  

end