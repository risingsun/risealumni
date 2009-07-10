require File.dirname(__FILE__) + '/../../test_helper'

class Admin::SiteContentsControllerTest < ActionController::TestCase
  def test_should_get_index
    @request.session[:user] = users(:admin).id
    get :index
    assert_response :success
    assert_not_nil assigns(:site_contents)
  end

  def test_should_get_new
    @request.session[:user] = users(:admin).id
    get :new
    assert_response :success
  end

  def test_should_create_site_content
    @request.session[:user] = users(:admin).id
    assert_difference('SiteContent.count') do
      post :create, :site_content => {:parent_id =>site_contents(:one).id,:name =>'footer_links' }
    end

    assert_redirected_to admin_site_content_path(assigns(:site_content))
  end

  def test_should_show_site_content
    @request.session[:user] = users(:admin).id
    get :show, :id => site_contents(:one).id
    assert_response :success
  end

  def test_should_get_edit
    @request.session[:user] = users(:admin).id
    get :edit, :id => site_contents(:one).id
    assert_response :success
  end

  def test_should_update_site_content
    @request.session[:user] = users(:admin).id
    put :update, :id => site_contents(:one).id, :site_content => {:parent_id =>site_contents(:one).id,:name =>'footer_links'}
    assert_redirected_to admin_site_content_path(assigns(:site_content))
  end

  def test_should_destroy_site_content
    @request.session[:user] = users(:admin).id
    assert_difference('SiteContent.count', -1) do
      delete :destroy, :id => site_contents(:one).id
    end

    assert_redirected_to admin_site_contents_path
  end
end
