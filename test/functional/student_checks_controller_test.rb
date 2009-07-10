require File.dirname(__FILE__) + '/../test_helper'

class StudentChecksControllerTest < ActionController::TestCase
  def setup
    @controller = StudentChecksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:admin)
  end
  
  def test_should_get_index
    @request.session[:user] = users(:admin)
    get :index,{:all => true}
    assert_not_nil assigns(:student_checks)
    assert_template 'index'
  end

  def test_should_get_new
    @request.session[:user] = users(:admin)
    get :new
    assert_response :success
  end

  def test_should_create_student_check
    assert_difference('StudentCheck.count') do
      @request.session[:user] = users(:admin)
      post :create, :student_check => {:name => 'ravi yadav', :year => '2006' }
    end

    assert_redirected_to student_checks_path
  end
  def test_should_not_create_student_check
    @request.session[:user] = users(:admin)
    post :create, :student_check => {:name => 'ravi yadav'}
    assert_response :success
    assert_template 'new'
  end

  def test_should_get_edit
    @request.session[:user] = users(:admin)
    get :edit, :id => student_checks(:student1).id
    assert_response :success
  end

  def test_should_update_student_check
    @request.session[:user] = users(:admin)
    put :update, :id => student_checks(:student1).id, :student_check => {:name => 'pooja' },:commit =>'Update and Return'
    assert_redirected_to student_checks_path
  end
  def test_should_update_student_check_and_then_edit
    @request.session[:user] = users(:admin)
    put :update, :id => student_checks(:student1).id, :student_check => {:name => 'pooja' },:commit => 'Update and Edit'
    assert_redirected_to edit_student_check_path(student_checks(:student1).id)
  end
  def test_should_update_student_check_and_then_create_another
    @request.session[:user] = users(:admin)
    put :update, :id => student_checks(:student1).id, :student_check => {:name => 'pooja' },:commit => 'Update and Add Another'
    assert_redirected_to new_student_check_path
  end
  def test_should_not_update_student_check
    @request.session[:user] = users(:admin)
    put :update, :id => student_checks(:student1).id, :student_check => {:year => nil }
    assert_response :success
  end
   
  def test_should_destroy_student_check
    assert_difference('StudentCheck.count', -1) do
      @request.session[:user] = users(:admin)
      delete :destroy, :id => student_checks(:student1).id
    end

    assert_redirected_to student_checks_path
  end
  def test_should_send_bulk_invite
    @request.session[:user] = users(:admin)
    post :send_bulk_invite
    assert_equal 'Bulk Invites sent.', flash[:notice]
    assert_redirected_to '/admin'
  end
  
  def test_should_send_invite
    @request.session[:user] = users(:admin)
    post :send_invite, :id => student_checks(:student1).id
    assert_equal 'Invite sent.', flash[:notice]
    assert_redirected_to '/admin'
  end
  
  def test_should_view_year_students
    @request.session[:user] = users(:admin)
    get :view_year_students,:year =>'2001'
    assert_not_nil assigns(:student_check)
    assert_response :success
  end
end
