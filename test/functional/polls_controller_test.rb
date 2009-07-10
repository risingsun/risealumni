require File.dirname(__FILE__) + '/../test_helper'

class PollsControllerTest < ActionController::TestCase

  def setup
    @request    = ActionController::TestRequest.new
    @p = profiles(:user)
  end
  
  def test_should_get_index
    @request.session[:user] = users(:user)
    get :index,:profile_id => @p.id
    assert_response :success
    assert_not_nil assigns(:polls)
  end
  
  def test_should_get_index_but_donnot_have_poll
    @request.session[:user] = users(:user3)
    get :index,:profile_id => profiles(:user3).id
    assert flash[:notice] == 'You have not create any polls. Try creating one now.'
    assert_redirected_to new_profile_poll_path(profiles(:user3))
  end
  
  def test_should_get_new
    @request.session[:user] = users(:user)
    get :new,:profile_id => @p.id
    assert_response :success
  end
  
  def test_should_create_poll
    @request.session[:user] = users(:user).id
    assert_difference('Poll.count') do
      post :create,:profile_id => @p.id, :poll => { :question => "Which color do you like most? " ,
        :poll_option_attributes => {:new => {"0" => {:option => "Red"}}}}
    end
    assert_redirected_to profile_polls_path(@p)
  end
  
  def test_should_try_to_create_poll
    @request.session[:user] = users(:user).id
    post :create,:profile_id => @p.id, :poll => { :question => "Which color do you like most? "}
    assert_response :success
  end
  
  def test_should_get_edit_poll
    @request.session[:user] = users(:user)
    get :edit,:profile_id => @p.id,:id => polls(:poll_1).id
    assert_response :success
  end
  
  def test_should_post_update_poll
    @request.session[:user] = users(:user)
    put :update,:profile_id => @p.id,:id => polls(:poll_1).id,:poll => { :question => "Which color do you like most? "}
    assert_redirected_to profile_polls_path(@p)
  end
  
  def test_should_try_post_update_poll
    @request.session[:user] = users(:user)
    put :update,:profile_id => @p.id,:id => polls(:poll_1).id,:poll => { :question => nil}
    assert_response :success
  end
  
  def test_should_destroy_poll
    assert_difference('Poll.count', -1) do
      @request.session[:user] = users(:user).id
      delete :destroy,:profile_id => @p.id, :id => polls(:poll_1).id
    end

    assert_redirected_to profile_polls_path(@p)
  end
  
  def test_should_close_poll
    @request.session[:user] = users(:user)
    get :poll_close,:profile_id => @p.id,:id => polls(:poll_1).id
    assert_redirected_to profile_polls_path(@p)
  end
  
  def test_should_show_poll
    @request.session[:user] = users(:user)
    get :show,:profile_id => @p.id,:id => polls(:poll_1).id
    assert_response :success
  end
  
end
