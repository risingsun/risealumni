require File.dirname(__FILE__) + '/../test_helper'

class AnnouncementsControllerTest < ActionController::TestCase
  def test_should_get_index
    @request.session[:user] = users(:admin).id
    get :index
    assert_response :success
    assert_not_nil assigns(:announcements)
  end

  def test_should_get_new
    @request.session[:user] = users(:admin).id
    get :new
    assert_response :success
  end

  def test_should_create_announcement
    assert_difference('Announcement.count') do
      @request.session[:user] = users(:admin).id
      post :create, :announcement => { :starts_at => Date.today, 
                                       :ends_at => Date.today+2.days, 
                                       :message => 'some message' }
    end

    assert_redirected_to announcements_path
  end
  
  def test_should_not_create_announcement
    @request.session[:user] = users(:admin).id
    post :create, :announcement => { }
    assert_equal('Announcement was not Successfully created',flash[:notice])
    assert_response :success
  end
  def test_try_to_create_announcement_nil_startdate_and_lastdate
    @request.session[:user] = users(:admin).id
    post :create, :announcement => {:message =>'some message' }
    assert_equal('Announcement was not Successfully created',flash[:notice])
    assert_response :success
  end
  def test_should_get_edit
    @request.session[:user] = users(:admin).id
    get :edit, :id => announcements(:one).id
    assert_response :success
  end

  def test_should_update_announcement
    @request.session[:user] = users(:admin).id
    put :update, :id => announcements(:one).id, :announcement => {:message => 'Due to same' }
    assert_equal('Announcement was successfully updated.',flash[:notice])
    assert_redirected_to announcements_path
  end 
  
  def test_should_not_update_announcement
    @request.session[:user] = users(:admin).id
    put :update, :id => announcements(:one).id, :announcement => {:message => nil }
    assert_equal('Announcement was not successfully updated',flash[:notice])
    assert_response :success
    assert_template 'announcements/edit'
  end

  def test_should_destroy_announcement
    assert_difference('Announcement.count', -1) do
      @request.session[:user] = users(:admin).id
      delete :destroy, :id => announcements(:one).id
    end

    assert_redirected_to announcements_path
  end
end
