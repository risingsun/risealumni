require File.dirname(__FILE__) + '/../test_helper'

class InvitationsControllerTest < ActionController::TestCase
  
  def setup
    @controller = InvitationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  should 'render to new invitation' do
    @request.session[:user] = users(:user).id
    get :new, :profile_id => profiles(:user).id
    assert_response :success
    assert_template 'new'
  end
  
  should 'create invitation if email is valid' do
    @request.session[:user] = users(:user).id
    post :create, {:profile_id => profiles(:user).id, :invitation => {:emails => ('aaaa@gmasi.com')}}
    assert assigns(:invites)
    assert_response :success   
  end
   
  should 'create invitation if email is blank' do
    @request.session[:user] = users(:user).id
    post :create, {:profile_id => profiles(:user).id, :invitation => {:emails => ('')}}
    assert_equal 'Seem like there was an error sending your invites', flash.now[:error]
    assert_equal 'No Emails found', assigns(:error)
    assert assigns(:invites).blank?
    assert_template 'new'
  end
 
  should 'create invitation if email is invalid' do
    @request.session[:user] = users(:user).id
    post :create, {:profile_id => profiles(:user).id, :invitation => {:emails => ('@anurag')}}
    assert_equal 'Seem like there was an error sending your invites', flash.now[:error]
    assert assigns(:invites).blank?
    assert_template 'new'
  end
    
end