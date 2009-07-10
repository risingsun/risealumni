require File.dirname(__FILE__) + '/../../test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  context 'on Get to :index' do 
    setup do
      @request.session[:user] = users(:admin).id
      get :index
   end
   should_respond_with :success
 end
 
  context 'on Put to :update' do
    setup do
      @request.session[:user] = users(:admin).id
      put :update, :id => profiles(:admin)
    end
    should_respond_with :success
    should_assign_to :profile
  end
  
  context 'on Put to not :update' do
    setup do
      @request.session[:user] = users(:admin).id
      put :update, :id => profiles(:user2)
    end
    should_respond_with :success
  end
=begin  
  context 'on Delete to :destroy' do
    setup do
      @request.session[:user] = users(:admin).id
      delete :destroy, :id => profiles(:admin)
    end
    should_respond_with :success
  end
  
  context 'on Delete to not :destroy' do
    setup do
      @request.session[:user] = users(:admin).id
      delete :destroy, :id => profiles(:user2)
    end
    should_respond_with :success
  end
=end
  end
