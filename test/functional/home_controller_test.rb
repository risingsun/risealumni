require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase
  
  
  should 'render home page' do
    assert_nothing_raised do
      get :index
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns(:home_data)
    end
  end

  should 'render about_us page' do
    assert_nothing_raised do
      get :show, :page => 'about_us'
      assert_response :success
      assert_template 'about_us'
    end
  end
  
  should 'render tos page' do
    assert_nothing_raised do
      get :show, :page => 'tos'
      assert_response :success
      assert_template 'tos'
    end
  end
  should 'render credits page' do
    assert_nothing_raised do
      get :show, :page => 'credits'
      assert_response :success
      assert_template 'credits'
    end
  end
  
  should 'render history page' do
    assert_nothing_raised do
      get :show, :page => 'history'
      assert_response :success
      assert_template 'history'
    end
  end
  
  should 'render members page' do
    assert_nothing_raised do
      get :show, :page => 'members'
      assert_response :success
      assert_template 'members'
    end
  end
  
  should 'render contact page' do
    assert_nothing_raised do
      get :show, :page => 'contact'
      assert_response :success
      assert_template 'contact'
    end
  end
  
  should 'newest_members' do
    assert_nothing_raised do
      get :newest_members, :format => 'rss'
      assert_response :success
    end
  end 
  
  should 'latest_comments' do
    assert_nothing_raised do
      get :latest_comments, :format => 'rss'
      assert_response :success
    end
  end 
  should 'render gallery but no set_id' do
    assert_nothing_raised do
      get :gallery  
      assert_response :success
      assert_template 'gallery'
    end
  end
  should 'render gallery' do
    assert_nothing_raised do
      get :gallery ,:set_id => '123445'
      assert_response :success
      assert_template 'gallery'
    end
  end  
end